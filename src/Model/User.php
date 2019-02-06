<?php

namespace ExampleApp\Model;

use Jenssegers\Mongodb\Eloquent\Model as Eloquent;

class User extends Eloquent
{
    /**
     * @var string
     */
    protected $collection = 'user';
}
