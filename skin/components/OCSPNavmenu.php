<?php

namespace Skins\Chameleon\Components;

use Html;

/**
 * The OCSPNavmenu class.
 */
class OCSPNavmenu extends Component {

	/**
	 * Builds the HTML code for this component
	 *
	 * @return string the HTML code
	 */
	public function getHtml() {
		return $this->indent() . '<!-- OCSPNavmenu -->' . $this->indent() . Html::openElement( 'div',
				[ 'class' => $this->getClassString(),
					'role' => 'banner', ] ) . $this->indent( 1 ) . wfMessage( 'Ws-navmenu' )->parse() .
			$this->indent( -1 ) . '</div>' . "\n";
	}
}
