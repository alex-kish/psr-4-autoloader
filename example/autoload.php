<?php

require_once __DIR__ . '/../src/Autoloader.php';

$loader = new Autoloader();
$loader->register();

$loader->addNamespace('App', __DIR__ . '/src');

