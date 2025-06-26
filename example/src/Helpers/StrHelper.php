<?php

namespace App\Helpers;

class StrHelper
{
    public static function random($length = 16): string
    {
        return bin2hex(random_bytes($length));
    }
}
