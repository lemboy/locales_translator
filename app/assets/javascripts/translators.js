
// Show/hide machine-translation buttons
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

// Change upload form action, depending on file type (locales or draft) 
  $( document ).on( 'click', '#upload-locale', function(e){
  	e.preventDefault();
		$('#load-form').get(0).setAttribute('action', Routes.translators_upload_file_path());
		$('#src-file').get(0).setAttribute('accept', '.yml');
    $("#src-file").trigger('click');
  });
  $( document ).on( 'click', '#upload-draft', function(e){
  	e.preventDefault();
		$('#load-form').get(0).setAttribute('action', Routes.translators_upload_draft_path());
		$('#src-file').get(0).setAttribute('accept', '.json');
    $("#src-file").trigger('click');
  });

// Change save form action, depending on file type (locales or draft) 
  $( document ).on( 'click', '#save-locale', function(e){
  	e.preventDefault();
		$( '#transl-form' ).get(0).setAttribute('action', Routes.translators_save_file_path());
    $( '#transl-form' ).submit();
  });
  $( document ).on( 'click', '#save-draft', function(e){
  	e.preventDefault();
		$( '#transl-form' ).get(0).setAttribute('action', Routes.translators_save_draft_path());
    $( '#transl-form' ).submit();
  });

// Auto submit upload form when file selected
  $( document ).on( 'change', '#src-file',  function() {
  	showPleaseWait("File uploading process...");
    $( "#load-form" ).submit();
  });

// Machine-translate one key
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
      	url: Routes.translators_translate_path({tag_id: trgt_id, text: src_text, dir: transl_dir}),
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

// Machine-translate all keys
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
      url: Routes.translators_translate_all_path(),
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

// On file upload  
  $( "#load-form" ).bind('ajax:success', function() {
	  $('.select2').select2({width: 'element'});
    updateAutoTranslateAbility();
    treeView();
  	hidePleaseWait();
  });

// On select target language
  $( document ).on( 'change', '#trgt-lang',  function() {
    updateAutoTranslateAbility();
  });

})

