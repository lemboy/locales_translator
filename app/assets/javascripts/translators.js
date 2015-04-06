function showPleaseWait(message) {
  $( "#flash-message" ).addClass( "alert alert-info"  );
  $( "#flash-message" ).html( message );
};

function hidePleaseWait() {
  $( "#flash-message" ).html(""); 
  $( "#flash-message" ).removeClass();
};

function updateAutoTranslateAbility() {
  var srcLang = $( '#src-lang' ).val().indexOf( "*" );
  var trgtLang = $( '#trgt-lang' ).find( 'option:selected' ).text().indexOf( "*" );
  if ( srcLang < 0 || trgtLang < 0 ) {
    $( "span[class*='auto-transl']" ).attr( "data-disabled", "true" );
  } else {
    $( "span[class*='auto-transl']" ).attr( "data-disabled", "false" );
  }  
  $( '#trgt-file-name' ).attr("placeholder", $( '#trgt-lang' ).find( 'option:selected' ).val() + ".yml" );   
};

$( document ).ready( function() {
  $( document ).on( 'change', '#src-file',  function() {
    $( "#load-form" ).submit();
  });

  $( document ).on( 'change', '#draft-file',  function() {
    $( "#load-draft-form" ).submit();
  });
  
  $( document ).on( 'click', '.auto-transl',  function(event) {
    var translateIt = true;
    var id = event.target.id.match(/[0-9 -()+]+$/).join();
    var src_id  = "#src-array-" + id;
    var trgt_id  = "#trgt-array-" + id;
    if ($( trgt_id ).val()) {
    	translateIt = confirm("Field is not empty. Process?")
    }
    if (translateIt) {
      var src_text = $( src_id ).val();
      var transl_dir = $( '#src-lang-code' ).val() + "-" + $( '#trgt-lang' ).find( 'option:selected' ).val();
      $.ajax({
      	type: "GET",
      	url: "/translators/translate?tag_id=" + encodeURIComponent(trgt_id) + "&text=" + encodeURIComponent(src_text) + "&dir=" + transl_dir,
	      dataType: "script",
        beforeSend: function(){
					showPleaseWait("Translation in progress...");
        },
        success: function(data) {
					hidePleaseWait();
        }
      });
    }
  });

  $( document ).on( 'click', '.auto-transl-all',  function(event) {
    event.stopPropagation();
    var anyFieldIsFilled = $("textarea[id^='trgt-array']").filter(function() {
            return $.trim(this.value).length !== 0;
        }).length > 0;

    if (anyFieldIsFilled) {
      if (!confirm("Some fields is not empty. Process?")) {
        return false;
      }
    }
    $.ajax({
      type: "POST",
      url: $("#transl-form").attr('action'),
      data: $("#transl-form").serialize(),
      dataType: "script",
      beforeSend: function(){
				showPleaseWait("Translation in progress...");
      },
      success: function(data) {
				hidePleaseWait();
      }
    });
  });

	$(document).on('submit','form#load-form',function(){
  	showPleaseWait("File uploading process...");
	});
  
  $( "#load-form" ).bind('ajax:success', function() {
    updateAutoTranslateAbility();
    treeView();
  	hidePleaseWait();
  });

  $( document ).on( 'change', '#trgt-lang',  function() {
    updateAutoTranslateAbility();
  });


})

