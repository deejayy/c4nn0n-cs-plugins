#include <amxmodx>

// meta

#define PLUGIN_NAME		"Message Advertisement filter"
#define PLUGIN_VERSION	"0.56"
#define PLUGIN_AUTHOR	"deejayy"

#define BANNER			"-MAF- Message Advertisement filter loaded"

// constants

// globals

// registered commands

public plugin_init() {
	register_plugin(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR)
	log_message(BANNER)
}

// access to globals

// broadcasted kill message handler

// =========================================================
// =========================================================
// =========================================================

