# View xhprof profiler reports using docker compose

1. Install `xhprof` php extension on target machine (see [xhprof pecl package](https://pecl.php.net/package/xhprof))
2. Configure `xprof` php extension output directory (see below)
3. Use the code snippet to create profile (see below)
4. Clone this repository to local directory and use `git submodule init`
5. Copy `*.xhprof` files from xhprof output directory on server to `./data/` directory in this repository
6. Use `docker compose up` and open http://localhost:8080/
7. Dig into profiler reports 🤓

## Installing xhprof

You need both PHP extension and PHP classes library.

1. Install xhprof either from PECL or distro's package repositories: https://pecl.php.net/package/xhprof
2. Copy `xhprof_lib/` from [github.com/longxinH/xhprof](https://github.com/longxinH/xhprof) to your project (e.g. to `src/xhprof/xhprof_lib/`)

## Configuring xhprof output directory

Create `90-xhprof-custom.ini` file in php configs directory (e.g. `/etc/php.d/` on RedHat / Fedora / Centos / Alma Linux):

```ini
xhprof.output_dir = '/var/www/data/xhprof'

;; For advanced setups:
; xhprof.collect_additional_info = 0
; xhprof.sampling_interval = 100000
```

## Code snippet to create xhprof profiles

- Add snippet below at the beginning of `index.php` or another PHP script.
- Fix all `TODO:` comments in snippet

```php
if (extension_loaded('xhprof') && !function_exists('do_xhprof_profile')) {
    function do_xhprof_profile()
    {
        // TODO: configure minimal PHP script duration.
        $minDurationToProfile = 2.0;
        $startedAt = microtime(true);
        xhprof_enable(XHPROF_FLAGS_CPU | XHPROF_FLAGS_NO_BUILTINS);
        try {
            register_shutdown_function(function () use ($startedAt, $minDurationToProfile) {
                register_shutdown_function(function () use ($startedAt, $minDurationToProfile) {
                    try {
                        $xhprofData = xhprof_disable();
                        $duration = microtime(true) - $startedAt;
                        if ($duration < $minDurationToProfile) {
                            return;
                        }
                        $requestUrl = $_SERVER['REQUEST_URI'] ?? '/';
                        // TODO: blacklist any URL paths using `str_contains` PHP function.

                        $prefix = trim(preg_replace('/[^a-zA-Z0-9]+/', '-', $requestUrl), '-')
                            . '-' . str_replace('.', '-', sprintf('%.2f', $duration)) . 's';

                        // TODO: check relative path to xhprof
                        require_once __DIR__ . '/../src/xhprof/xhprof_lib/utils/xhprof_lib.php';
                        require_once __DIR__ . '/../src/xhprof/xhprof_lib/utils/xhprof_runs.php';
                        $runs = new XHProfRuns_Default();
                        $runs->save_run($xhprofData, $prefix);
                    } catch (Throwable $e) {
                    }
                });
            });
        } catch (Throwable $e) {
        }
    }
    do_xhprof_profile();
}
```

## See also

1. My example application with xhprof profiling: https://github.com/sergey-shambir/php-xhprof-example
2. Profile extension: https://github.com/longxinH/xhprof
3. More powerful and complex solution: https://github.com/perftools/xhgui
