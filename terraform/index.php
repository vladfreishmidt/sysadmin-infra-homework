<?php
header('Content-Type: application/json');

$uri = $_SERVER['REQUEST_URI'];
$appEnv = getenv('APP_ENV') ?: 'dev';

if ($uri === '/healthz' || $uri === '/healthz/') {
    // Health check endpoint
    echo json_encode([
        'status' => 'ok',
        'service' => 'nginx',
        'env' => $appEnv
    ]);
} else {
    // Main endpoint
    echo json_encode([
        'message' => 'Welcome to SysAdmin Infrastructure Test',
        'environment' => $appEnv,
        'php_version' => phpversion(),
        'timestamp' => date('Y-m-d H:i:s')
    ]);
}