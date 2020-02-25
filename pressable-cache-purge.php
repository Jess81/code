<?php
/*
Plugin Name: Pressable Cache Purge
Plugin URI: https://github.com/Jess81/code
Description: Adds a Cache Purge button to the admin bar
Author: Jess Nunez
Version: 1.0.0
Author URI: https://github.com/Jess81/
License: GPL2
*/


add_action('admin_bar_menu', 'cache_add_item', 100);

function cache_add_item( $admin_bar ){
  if(is_admin()) {
    global $pagenow;
    $admin_bar->add_menu( array( 'id'=>'cache-purge','title'=>'Cache Purge','href'=>'#' ) );
  }
}


add_action( 'admin_footer', 'cache_purge_action_js' );

function cache_purge_action_js() { ?>
  <script type="text/javascript" >
     jQuery("li#wp-admin-bar-cache-purge .ab-item").on( "click", function() {
        var data = {
                      'action': 'pressable_cache_purge',
                    };

        jQuery.post(ajaxurl, data, function(response) {
           alert( response );
        });

      });
  </script> <?php
}

add_action( 'wp_ajax_pressable_cache_purge', 'pressable_cache_purge_callback' );

function pressable_cache_purge_callback() {
    wp_cache_flush();
    $response = "Cache Purged";
    echo $response;
    wp_die(); 
} 

?>
