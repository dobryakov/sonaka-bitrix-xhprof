<?php
declare(strict_types=1);

if (!extension_loaded('xhprof')) {
    return;
}

$xhprofOn = isset($_GET['xhprof']) && (string) $_GET['xhprof'] === '1';
if (!$xhprofOn) {
    $qs = (string) ($_SERVER['QUERY_STRING'] ?? '');
    if ($qs !== '') {
        parse_str($qs, $qp);
        $xhprofOn = isset($qp['xhprof']) && (string) $qp['xhprof'] === '1';
    }
}
if (!$xhprofOn) {
    return;
}

xhprof_enable(XHPROF_FLAGS_CPU + XHPROF_FLAGS_MEMORY);

register_shutdown_function(static function (): void {
    $data = xhprof_disable();
    if (!is_array($data) || $data === []) {
        return;
    }
    require_once __DIR__ . '/xhprof_lib/utils/xhprof_lib.php';
    require_once __DIR__ . '/xhprof_lib/utils/xhprof_runs.php';
    $runs = new XHProfRuns_Default();
    $runs->save_run($data, 'bitrix');
});
