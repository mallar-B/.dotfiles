pragma Singleton
import QtQuick

QtObject{
	// Default theme
	readonly property color red: Qt.rgba(0.898, 0.455, 0.455, 1.0) // #E57474
	readonly property color green: Qt.rgba(0.549, 0.812, 0.494, 1.0) // #8CCF7E
	readonly property color yellow: Qt.rgba(0.898, 0.780, 0.420, 1.0) // #E5C76B
	readonly property color blue: Qt.rgba(0.404, 0.690, 0.910, 1.0) // #67B0E8
	readonly property color magenta: Qt.rgba(0.769, 0.498, 0.835, 1.0) // #C47FD5
	readonly property color cyan: Qt.rgba(0.424, 0.749, 0.749, 1.0) // #6CBFBF

	// lightened versions of Default
	readonly property color light_red: Qt.rgba(0.949, 0.545, 0.510, 1.0) // #F28B82
	readonly property color light_green: Qt.rgba(0.659, 0.847, 0.627, 1.0) // #A8D89F
	readonly property color light_yellow: Qt.rgba(0.953, 0.851, 0.541, 1.0) // #F3D98A
	readonly property color light_blue: Qt.rgba(0.557, 0.792, 0.949, 1.0) // #8ECCF2
	readonly property color light_magenta: Qt.rgba(0.851, 0.639, 0.890, 1.0) // #D9A3E3
	readonly property color light_cyan: Qt.rgba(0.561, 0.839, 0.839, 1.0) // #8FD6D6

	// Extra
	readonly property color orange: Qt.rgba(0.965, 0.722, 0.561, 1.0) // #F6B890
	readonly property color purple: Qt.rgba(0.655, 0.616, 0.882, 1.0) // #A793E1
	readonly property color teal: Qt.rgba(0.482, 0.792, 0.769, 1.0) // #7BCAB9
	readonly property color pink: Qt.rgba(0.949, 0.655, 0.765, 1.0) // #F2A7C3
	readonly property color accent: Qt.rgba(0.361, 0.486, 0.980, 1.0) // #5C7BFA
	readonly property color gray: Qt.rgba(0.420, 0.463, 0.471, 1.0) // #6B7678
	readonly property color light_gray: Qt.rgba(0.541, 0.569, 0.573, 1.0) // #8A9192
	readonly property color dark_gray: Qt.rgba(0.184, 0.212, 0.220, 1.0) // #2F3638

	// Muted versions (with opacity)
	readonly property color muted_red: Qt.rgba(0.898, 0.455, 0.455, 0.1) // #E574741A
	readonly property color muted_green: Qt.rgba(0.549, 0.812, 0.494, 0.1) // #8CCF7E1A
	readonly property color muted_yellow: Qt.rgba(0.898, 0.780, 0.420, 0.1) // #E5C76B1A
	readonly property color muted_blue: Qt.rgba(0.173, 0.161, 0.200, 1.0) // #accde6

	readonly property color muted_magenta: Qt.rgba(0.769, 0.498, 0.835, 0.1) // #C47FD51A
	readonly property color muted_cyan: Qt.rgba(0.424, 0.749, 0.749, 0.1) // #6CBFBF1A
	readonly property color muted_orange: Qt.rgba(0.965, 0.722, 0.561, 0.1) // #F6B8901A
	readonly property color muted_purple: Qt.rgba(0.655, 0.616, 0.882, 0.1) // #A793E11A
	readonly property color muted_teal: Qt.rgba(0.482, 0.792, 0.769, 0.1) // #7BCAB91A
	readonly property color muted_pink: Qt.rgba(0.949, 0.655, 0.765, 0.1) // #F2A7C31A
	readonly property color muted_gray: Qt.rgba(0.420, 0.463, 0.471, 0.1) // #6B76781A

	readonly property color foreground_primary: Qt.rgba(0.855, 0.855, 0.855, 1.0) // #DADADA
	readonly property color foreground_secondary: Qt.rgba(0.702, 0.725, 0.722, 1.0) // #B3B9B8
	readonly property color background_primary: Qt.rgba(0.078, 0.106, 0.118, 1.0) // #141B1E
	readonly property color background_secondary: Qt.rgba(0.137, 0.165, 0.176, 1.0) // #232A2D
}
