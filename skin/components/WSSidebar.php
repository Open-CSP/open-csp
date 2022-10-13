<?php

namespace Skins\Chameleon\Components;

use Html;

/**
 * The WSFooter class.
 */
class WSSidebar extends Component {

	/**
	 * Builds the HTML code for this component
	 *
	 * @return string the HTML code
	 */
	public function getHtml() {
		return $this->indent() . '<!-- WSSidebar -->' . $this->indent() . Html::openElement( 'div',
				[ 'class' => $this->getClassString(),
					'role' => 'banner', ] ) . $this->indent( 1 ) . wfMessage( 'Ws-sidebar' )->parse() .
			$this->indent( -1 ) . '</div>' . "\n";
	}
}
