<?php

namespace Skins\Chameleon\Components;

use Html;

/**
 * The OCSPSubSidebar class.
 */
class OCSPSubSidebar extends Component {

	/**
	 * Builds the HTML code for this component
	 *
	 * @return string the HTML code
	 */
	public function getHtml() {
		return $this->indent() . '<!-- OCSPSubSidebar -->' . $this->indent() . Html::openElement( 'div',
				[ 'class' => $this->getClassString(),
					'role' => 'banner', ] ) . $this->indent( 1 ) . wfMessage( 'Ws-sub-sidebar' )->parse() .
			$this->indent( -1 ) . '</div>' . "\n";
	}
}
