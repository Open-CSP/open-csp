$( document ).ready( function () {
	// Start of esc save
	$( 'body.action-edit, body.action-submit' ).keydown( function () {
		var x = event.keyCode;
		if ( x == 27 ) {
			$.ajax( {
				url: '/api.php?action=query&meta=tokens&format=json',
				type: 'GET',
				dataType: 'json',
				success: function ( result ) {
					var token = result.query.tokens.csrftoken;

					$( "input[name='wpEditToken']" ).attr( "value", token );

					saveEdit();

				}
			} );
		} else {
			mw.confirmCloseWindow();
			$( '#wpSave, #wpPreview, #wpDiff' ).on( 'click', function () {
				$( window ).off( 'beforeunload' );
			} )
		}

	} )

	if ( $( 'body' ).hasClass( 'action-submit' ) ) {
		$( '#top' ).prepend( '<button class="btn btn-success enable-live-mode">Enable live mode</button>' );
		$( document ).on( 'click', '.enable-live-mode', function () {
			if ( $( this ).hasClass( 'btn-success' ) ) {
				liveMode();
				$( this ).removeClass( 'btn-success' );
				$( this ).text( 'Live mode is on' );
			} else {
				$( this ).addClass( 'btn-success' );
				$( 'body.action-submit textarea' ).off( "change keyup paste" );
				$( this ).text( 'Enable live mode' );
			}

		} );
	}
} );

window.saveEdit = function () {
	$.ajax( {
		url: $( 'form.mw-editform' ).attr( 'action' ),
		type: 'POST',
		data: $( 'form.mw-editform' ).serialize(),
		success: function ( html ) {
			$( window ).off( 'beforeunload' );
			mw.notify( 'Saved' );
			if ( $( 'body' ).hasClass( 'action-submit' ) ) {
				var parser = new DOMParser();
				var doc = parser.parseFromString( html, "text/html" );
				var elem = doc.querySelectorAll( '.mw-content-ltr' )[0];
				$( '.mw-content-ltr' ).html( elem );
			}
		}
	} )
};

window.liveMode = function () {
	var oldVal = "";
	$( 'body.action-submit textarea' ).on( "change keyup paste", function () {
		var currentVal = $( this ).val();
		if ( currentVal == oldVal ) {
			return; //check to prevent multiple simultaneous triggers
		}

		oldVal = currentVal;
		var text = encodeURIComponent( $( 'textarea' ).val() );

		$.ajax( {
			url: '/api.php?action=parse&format=json&formatversion=2&title=New&text=' + text + '&pst=&prop=text%7Cmodules%7Cjsconfigvars&preview=true&disableeditsection=true&uselang=en',
			dataType: 'json',
			success: function ( x ) {
				$( '#wikiPreview' ).html( x.parse.text );
			}
		} );
	} );
	/* End of Esc Save */


	/* Select2 */
	if ( $( 'select[data-inputtype="ws-select2"]' )[0] ) {
		mw.loader.load( '/extensions/WSForm/select2.min.css', 'text/css' );
		$.getScript( '/extensions/WSForm/select2.min.js' ).done( function () {
			$( 'select[data-inputtype="ws-select2"]' ).each( function () {
				var selectid = $( this ).attr( 'id' );
				var selectoptionsid = 'select2options-' + selectid;
				var select2config = $( "input#" + selectoptionsid ).val();
				var F = new Function( select2config );
				return ( F() );
			} );
		} );
	}
	/* end of select2 */

	/* ***** Loading multipleInstanceTemplates and WSShowOnSelect ***** */
	if ( $( '.WSmultipleTemplateWrapper' ) && !$( '.WSShowOnSelect' ) ) {
		$.getScript( '/wikis/modules/wsbasics/multipleInstanceTemplates.js' );
	}

	if ( $( '.WSShowOnSelect' ) && !$( '.WSmultipleTemplateWrapper' ) ) {
		$.getScript( '/wikis/modules/wsbasics/WSShowOnSelect.js' ).done( function () {
			WsShowOnSelect();
		} );
	}

	if ( $( '.WSShowOnSelect' ) && $( '.WSmultipleTemplateWrapper' ) ) {
		$.getScript( '/wikis/modules/wsbasics/WSShowOnSelect.js' ).done( function () {
			WsShowOnSelect();
			$.getScript( '/wikis/modules/wsbasics/multipleInstanceTemplates.js' ).done( function () {
				WsShowOnSelect();
			} );
		} );
	}
	/* ----- end of Loading multipleInstanceTemplates and WSShowOnSelect ----- */
};