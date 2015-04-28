function treeView () {
    $('.tree li:has(ul)').addClass('parent_li').find(' > span').attr('title', 'Collapse this branch');
    $( document ).on('click', '.tree li.parent_li > span', function (e) {
        e.stopPropagation();
        var children = $(this).parent('li.parent_li').find(' > ul > li');
        if (children.is(":visible")) {
            children.hide('fast');
            $(this).attr('title', 'Expand this branch').addClass('glyphicon-plus-sign').removeClass('glyphicon-minus-sign');
        } else {
            children.show('fast');
            $(this).attr('title', 'Collapse this branch').addClass('glyphicon-minus-sign').removeClass('glyphicon-plus-sign');
        }
        e.stopPropagation();
    });
	buttonCheckbox();
};

function buttonCheckbox() {
  // Settings
  var 
  	$widget = $('#button-checkbox'),
    $button = $widget.find('button'),
    $checkbox = $widget.find('input:checkbox'),
    $span = $widget.find('span'),
    $control = $('.tree .form-control'),
    settings = {
      on: {
        icon: 'glyphicon glyphicon-align-left',
        widthClass : 'form-control full-width'
      },
      off: {
        icon: 'glyphicon glyphicon-align-justify',
        widthClass : 'form-control long'
      }
    };

  // Event Handlers
  $button.on('click', function () {
    $checkbox.prop('checked', !$checkbox.is(':checked'));
    $checkbox.triggerHandler('change');
    updateDisplay();
  });
  $checkbox.on('change', function () {
    updateDisplay();
  });

  // Actions
  function updateDisplay() {
    var isChecked = $checkbox.is(':checked');

    // Set the button's state
    $button.data('state', (isChecked) ? "on" : "off");

    // Set the button's icon
    $span
      .removeClass()
      .addClass(settings[$button.data('state')].icon);

    $control
      .removeClass()
      .addClass(settings[$button.data('state')].widthClass);

  }

  // Initialization
  function init() {
    updateDisplay();
  }
  init();
};