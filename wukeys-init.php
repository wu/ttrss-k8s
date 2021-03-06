<?php
class WuKeys extends Plugin {
	private $host;

	function about() {
		return array(1.0,
			"Wu Custom Keyboard hotkeys",
			"wu");
	}

	function init($host) {
		$this->host = $host;

		$host->add_hook($host::HOOK_HOTKEY_MAP, $this);
	}

	function hook_hotkey_map($hotkeys) {

		$hotkeys["n"]		= "next_article_noscroll";
		$hotkeys["p"]		= "prev_article_noscroll";

		return $hotkeys;
	}

	function api_version() {
		return 2;
	}

}
?>
