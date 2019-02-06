<?php

use ExampleApp\Model\User;
use Slim\Http\Request;
use Slim\Http\Response;

// Routes

 $app->get('/insert/{firstname}/{lastname}', function (Request $request, Response $response, array $args) {
     $user = new User();
     $user->firstname = filter_var($args['firstname'], FILTER_SANITIZE_STRING);
     $user->lastname = filter_var($args['lastname'], FILTER_SANITIZE_STRING);
     $user->save();

     return $this->renderer->render(
       $response,
       'insert.phtml',
       ['user' => $user]
     );
 });

$app->get('/{lastname}', function (Request $request, Response $response, array $args) {
    $users = User::where('lastname', $args['lastname'] ?? '')->get();

    return $this->renderer->render(
      $response,
      'index.phtml',
      ['users' => $users]
    );
});
