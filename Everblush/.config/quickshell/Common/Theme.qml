pragma Singleton
import QtQuick

QtObject{
	// Default theme
	readonly property string red: "#e57474"
	readonly property string green: "#8ccf7e"
	readonly property string yellow: "#e5c76b"
	readonly property string blue: "#67b0e8"
	readonly property string magenta: "#c47fd5"
	readonly property string cyan: "#6cbfbf"

	// lightened versions of Default
	readonly property string light_red: "#f28b82"
	readonly property string light_green: "#a8d8a0"
	readonly property string light_yellow: "#f3d98a"
	readonly property string light_blue: "#8ecaf2"
	readonly property string light_magenta: "#d9a3e3"
	readonly property string light_cyan: "#8fd6d6"

	// Extra
	readonly property string orange: "#f6b88f"
	readonly property string purple: "#a79de1"
	readonly property string teal: "#7bcac4"
	readonly property string pink: "#f2a7c3"
	readonly property string accent: "#5c7cfa"

	readonly property string foreground_primary: "#dadada"
	readonly property string foreground_secondary:"#b3b9b8"
	readonly property string background_primary: "#141b1e"
	readonly property string background_secondary: "#232a2d"
}
