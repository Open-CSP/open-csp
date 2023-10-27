<?php

namespace Skins\Chameleon\Components;

use Html;

/**
 * The OCSPSubHeader class.
 */
class OCSPSubHeader extends Component {

	/**
	 * Builds the HTML code for this component
	 *
	 * @return string the HTML code
	 */
	public function getHtml() {
		return $this->indent() . '<!-- OCSPSubHeader -->' . $this->indent() . Html::openElement( 'div',
				[ 'class' => $this->getClassString(),
					'role' => 'banner', ] ) . $this->indent( 1 ) . wfMessage( 'Ws-sub-header' )->parse() .
			$this->indent( -1 ) . '</div>' . "\n";
	}
}
