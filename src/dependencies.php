<?php

use Illuminate\Database\Capsule\Manager;
use Psr\Container\ContainerInterface;

$container = $app->getContainer();
// view renderer
$container['renderer'] = function ($c) {
    $settings = $c->get('settings')['renderer'];

    return new Slim\Views\PhpRenderer($settings['template_path']);
};

$container['db'] = function (ContainerInterface $c) {
    $capsule = new Manager();
    $capsule->getDatabaseManager()->extend('mongodb', function ($config) {
        return new Jenssegers\Mongodb\Connection($config);
    });
    $capsule->addConnection($c->get('settings')['db']);
    $capsule->setAsGlobal();
    $capsule->bootEloquent();

    return $capsule;
};
