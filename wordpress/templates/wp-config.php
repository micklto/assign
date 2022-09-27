define('DB_NAME', '{{ wp_db_name }}');
define('DB_USER', '{{ wp_db_username }}');
define('DB_PASSWORD', '{{ wp_db_password }}');
define('DB_HOST', '{{ wp_db_host }}');
define('DB_CHARSET', 'utf8');
define('DB_COLLATE', '');
{{ wp_salt.stdout }}
$table_prefix  = '{{ wp_table_prefix }}';
define('WPLANG', '');
define('WP_DEBUG', {{ wp_debug_mode }});
if ( !defined('ABSPATH') )
    define('ABSPATH', dirname(__FILE__) . '/');
require_once(ABSPATH . 'wp-settings.php');
