<?php
/**
 * File holding the WSFooter component class
 *
 * This file is part of the additions for the wiki of Broad Horizon.
 *
 * @copyright 2013 - 2014, Ad Strack van Schijndel
 */

namespace Skins\Chameleon\Components;

use Html;

/**
 * The WSFooter class.
 */
class WSFooter extends Component {

	/**
	 * Builds the HTML code for this component
	 *
	 * @return string the HTML code
	 */
	public function getHtml() {
		return $this->indent() . '<!-- WSFooter -->' . $this->indent() . Html::openElement( 'div',
				[ 'class' => $this->getClassString(),
					'role' => 'banner', ] ) . $this->indent( 1 ) . wfMessage( 'Ws-footer' )->parse() .
			$this->indent( -1 ) . '</div>' . "\n";
	}
}
