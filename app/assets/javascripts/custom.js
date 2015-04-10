function cleanMessage() {
	$( '#flash-message' ).show();
  $( "#flash-message" ).html( "" ); 
  $( "#flash-message" ).removeClass();
};

// Show/hide "Pleas Wait" message
function showPleaseWait( message ) {
	cleanMessage();
  $( "#flash-message" ).addClass( "alert alert-info"  );
  $( "#flash-message" ).html( message );
};
function hidePleaseWait() {
	cleanMessage();
};

$( document ).ready( function() {
	$( document ).on('click', '.alert .close', function(e) {
    $('#flash-message').hide();
	});
});