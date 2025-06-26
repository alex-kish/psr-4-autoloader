<?php

use App\Helpers\StrHelper;
use App\Services\HelloWorld;

require_once __DIR__ . '/autoload.php';

$randomStr = StrHelper::random(9);

$helloWorld = new HelloWorld();
$helloWorld->sayHello();
