<?php

namespace Skins\Chameleon\Components;

use Html;

/**
 * The OCSPHeader class.
 */
class OCSPHeader extends Component {

	/**
	 * Builds the HTML code for this component
	 *
	 * @return string the HTML code
	 */
	public function getHtml() {
		return $this->indent() . '<!-- OCSPHeader -->' . $this->indent() . Html::openElement( 'div',
				[ 'class' => $this->getClassString(),
					'role' => 'banner', ] ) . $this->indent( 1 ) . wfMessage( 'Ws-header' )->parse() .
			$this->indent( -1 ) . '</div>' . "\n";
	}
}
