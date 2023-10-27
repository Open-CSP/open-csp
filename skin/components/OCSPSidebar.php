<?php

namespace Skins\Chameleon\Components;

use Html;

/**
 * The OCSPSidebar class.
 */
class OCSPSidebar extends Component {

	/**
	 * Builds the HTML code for this component
	 *
	 * @return string the HTML code
	 */
	public function getHtml() {
		return $this->indent() . '<!-- OCSPSidebar -->' . $this->indent() . Html::openElement( 'div',
				[ 'class' => $this->getClassString(),
					'role' => 'banner', ] ) . $this->indent( 1 ) . wfMessage( 'Csp-sidebar' )->parse() .
			$this->indent( -1 ) . '</div>' . "\n";
	}
}
