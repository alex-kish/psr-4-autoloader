<?php

declare(strict_types=1);

/**
 * PSR-4 autoloader for class loading
 * 
 * @author Your Name
 * @version 1.0
 */
class Autoloader
{
    /** @var array<string, list<string>> Array of namespace prefixes and their corresponding directories */
    protected array $prefixes = [];

    /** @var array<string, string> Cache for resolved file paths: class name => file path */
    protected array $fileCache = [];

    /**
     * Registers the autoloader in spl_autoload_register
     */
    public function register(): void
    {
        spl_autoload_register([$this, 'loadClass']);
    }

    /**
     * Adds a new namespace for autoloading
     *
     * @param string $prefix Namespace prefix
     * @param string $base_dir Base directory for classes
     * @param bool $prepend Whether to add directory at the beginning of the list
     * @throws InvalidArgumentException If prefix or base_dir is invalid or base_dir is not an absolute path
     */
    public function addNamespace(string $prefix, string $base_dir, bool $prepend = false): void
    {
        if (empty($prefix) || !preg_match('/^[a-zA-Z_\x7f-\xff\\][a-zA-Z0-9_\x7f-\xff\\]*$/u', $prefix)) {
            throw new InvalidArgumentException('Invalid namespace prefix: ' . $prefix);
        }

        $real_base_dir = realpath($base_dir);
        if ($real_base_dir === false || !is_dir($real_base_dir)) {
            throw new InvalidArgumentException('Base directory "' . $base_dir . '" does not exist or is not a directory.');
        }
        
        $normalized_prefix = trim($prefix, '\\') . '\\';
        $normalized_base_dir = rtrim($real_base_dir, DIRECTORY_SEPARATOR) . DIRECTORY_SEPARATOR;

        if (!isset($this->prefixes[$normalized_prefix])) {
            $this->prefixes[$normalized_prefix] = [];
        }

        if ($prepend) {
            array_unshift($this->prefixes[$normalized_prefix], $normalized_base_dir);
        } else {
            $this->prefixes[$normalized_prefix][] = $normalized_base_dir;
        }
    }

    /**
     * Loads a class by its fully qualified name
     *
     * @param string $class Fully qualified class name
     * @throws InvalidArgumentException If class name is invalid
     */
    public function loadClass(string $class): void
    {
        if (empty($class) || !preg_match('/^[a-zA-Z_\x7f-\xff\\][a-zA-Z0-9_\x7f-\xff\\]*$/u', $class)) {
            throw new InvalidArgumentException('Invalid class name: ' . $class);
        }

        if (isset($this->fileCache[$class])) {
            $file = $this->fileCache[$class];
            if (file_exists($file)) { 
                require $file;
                return;
            }
            unset($this->fileCache[$class]);
        }

        $currentPrefixToSearch = $class;

        while (false !== $pos = strrpos($currentPrefixToSearch, '\\')) {
            $namespacePrefix = substr($class, 0, $pos + 1);
            $relativeClass = substr($class, $pos + 1);

            $fileLoaded = $this->loadMappedFile($class, $namespacePrefix, $relativeClass);

            if ($fileLoaded) {
                return;
            }

            $currentPrefixToSearch = rtrim($namespacePrefix, '\\');
        }
        
        if (strpos($class, '\\') === false) {
            if ($this->loadMappedFile($class, '', $class)) {
                return;
            }
        }
    }

    /**
     * Loads a class file by its original full name, the current namespace prefix being tested, and the relative class part.
     *
     * @param string $originalClass The original fully qualified class name (for caching).
     * @param string $namespacePrefix The namespace prefix currently being checked (e.g., "Foo\Bar\"). Can be empty for global namespace.
     * @param string $relativeClass The relative class name part (e.g., "Baz").
     * @return bool Whether the file was successfully loaded.
     * @throws InvalidArgumentException If relative_class name is invalid.
     * @throws RuntimeException If a file is found but poses a security risk (e.g., outside base directory).
     */
    protected function loadMappedFile(string $originalClass, string $namespacePrefix, string $relativeClass): bool
    {
        if (!isset($this->prefixes[$namespacePrefix])) {
            return false;
        }

        if (empty($relativeClass) || strpos($relativeClass, '\\') !== false || !preg_match('/^[a-zA-Z_\x7f-\xff][a-zA-Z0-9_\x7f-\xff]*$/u', $relativeClass)) {
            throw new InvalidArgumentException('Invalid relative class name part: ' . $relativeClass);
        }

        foreach ($this->prefixes[$namespacePrefix] as $baseDir) {
            $file = $baseDir
                  . str_replace('\\', DIRECTORY_SEPARATOR, $relativeClass)
                  . '.php';

            if (file_exists($file)) {
                $realFile = realpath($file);
                if ($realFile === false) {
                    continue; 
                }

                if (!str_starts_with($realFile, $baseDir) || $realFile === rtrim($baseDir, DIRECTORY_SEPARATOR)) {
                    throw new RuntimeException(
                        'Security: Attempt to load file outside of allowed base directory or invalid file path. File: "' . $file . 
                        '", Base: "' . $baseDir . '"' 
                    );
                }
                
                require $realFile;
                $this->fileCache[$originalClass] = $realFile;
                return true;
            }
        }

        return false;
    }
}
