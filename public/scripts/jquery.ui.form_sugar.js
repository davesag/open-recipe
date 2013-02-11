// the query.ui.form_sugar plugin is applied to a jQuery form object.
// It wraps all input fields in a label to identify the field, and a matching label to carry any validation errors.
// It does not do this for input fields within a span or td cell however.
// It adds a hover handler to all fields with the 'hover' class attached.
// It adds all of the appropriate CSS classes to conform the form with the
// jQuery UI ThemeRoller.
//
// To add custom submit actions and form validation, using the jQuery Validation plugin
// provide init options according to the following object graph.
// {
//    buttons: {'button-id': {label: "My Button", handler: function(event) {} [,…]},
//    fields {'field-id': {label: "My Field"[, validation: {/*jQuery Validation Rules*/}, messages: {/*jQuery Validation Messages*/}]} [,…]}
// }
// 
// An example:
//   {buttons: {
//    'choose-photo': {label: "Choose Photo", handler: 'choose-photo'},
//    'save-recipe': {label: "Save Recipe", handler: 'save-recipe'},
//    'cancel': {label: "Cancel", handler: 'cancel'}
//   },
//   fields: {
//     'recipe-name': {label: "Name", validation: {
//       required: true
//      },
//      messages: 'You must provide a name.'
//     },
//     'serves': {label: "Serves", validation: {
//       required: true,
//       number: true
//      },
//      messages: {
//        required: 'You must say how many people this recipe serves.',
//        number: 'The serving suggestion must be a number.'
//      }
//     },
//     'description': {label: "Description"},
//     'prep-time': {label: "Prep Time"},
//     'cooking-time': {label: "Cooking Time"},
//     'requirements': {label: "Requirements"},
//     'the-method': {label: "Method"},
//     'ingredients': {label: "Ingredients"}
//   }}
$(function() {
  $.widget("ui.form_sugar",{
    _init: function(){
      // console.log ('form_sugar init.', this.option());
      var options = this.option(),  // might want to do ome checking of this now.
          object = this,
          form = this.element,
          validation_rules = {},
          validation_messages = {},
          inputs = form.find("input , select ,textarea"),
          field, field_id, fModel, vr;

      form.find("fieldset").addClass("ui-widget-content");
      form.find("legend").addClass("ui-widget-header ui-corner-all");
      form.addClass("ui-widget");

      $.each(inputs,function(){
        field = $(this);
        field_id = field.attr('id');
        field.addClass('ui-state-default ui-corner-all');
        if (typeof field.attr('name') === 'undefined' || field.attr('name') === '') {
          field.attr('name', field_id); // so the jQuery Validator plugin works.
        } else if (field.attr('name') !== field_id) field_id = field.attr('name');
        // console.log("field name = ", field.attr('name'));
        fModel = options.fields[field.attr('name')];
        has_fModel = (typeof fModel !== 'undefined' && fModel != null);
        if (has_fModel) {
          // console.log("fModel for " + field_id, fModel);
          if (!(field.parent().is("span") || field.parent().is("td"))) {
            $('<label for="'+ field_id +'">' + fModel.label + '</label>').insertBefore(field);
            $('<label for="'+ field_id +'" generated="true" class="error"></label>').insertAfter(field);
          }
        }
        if(field.is(":reset, :submit")) object.buttons(this);
        else if(field.is(":checkbox")) object.checkboxes(this);
        else if(field.is("input[type='text']")||field.is("textarea")||field.is("input[type='password']")) object.textelements(this);
        else if(field.is(":radio")) object.radio(this);
        else if(field.is("select")) object.selector(this);

        if(field.hasClass("date")) field.datepicker();
        
        // apply any validation rules here.
        if (has_fModel && fModel.validation != null) {
          validation_rules[field.attr('name')] = fModel.validation;
          if (fModel.messages != null) validation_messages[field.attr('name')] = fModel.messages;
        }
      });

      vr = {
        debug: true,  // todo: turn this off.
        submitHandler: function(f) {  // todo: review the need for this.
          // do nothing
          console.log("form submit called for ", f);
          return false;
        },
        rules: validation_rules,
        messages: validation_messages
      }
      // console.log("setting validation rules:", vr);
      form.validate(vr);  // activate the validation handler.

      $(".hover").hover(function(){
        $(this).addClass("ui-state-hover");
      }, function(){
        $(this).removeClass("ui-state-hover");
      });
      return object;
    },
    textelements: function(element){
      $(element).bind({
        focusin: function() {
          $(this).toggleClass('ui-state-focus');
        },
        focusout: function() {
          $(this).toggleClass('ui-state-focus');
        }
      });

    },
    buttons:function(element) {
      var elm = $(element).button();
      elm.click(this.option().buttons[elm.attr('id')].handler);
      elm.val(this.option().buttons[elm.attr('id')].label);
      if (elm.is(":reset")) elm.addClass("cancel ui-priority-secondary ui-corner-all hover");
      if (elm.is(":disabled")) elm.addClass('ui-state-disabled');
    },
    checkboxes: function(element){
      $(element).wrap("<span/>");
      var parent =  $(element).parent();
      $(element).addClass("ui-helper-hidden");
      parent.css({width:16,height:16,display:"block"});
      parent.wrap("<span class='ui-state-default ui-corner-all' style='display:inline-block;width:16px;height:16px;margin-right:5px;'/>");
      parent.parent().addClass('hover');
      parent.parent("span").click(function(event){
        $(this).toggleClass("ui-state-active");
        parent.toggleClass("ui-icon ui-icon-check");
        $(element).click();
      });
    },
    radio: function(element){
      $(element).wrap("<span/>");
      var parent =  $(element).parent();
      $(element).addClass("ui-helper-hidden");
      parent.addClass("ui-icon ui-icon-radio-off hover");
      parent.wrap("<span class='ui-state-default ui-corner-all' style='display:inline-block;width:16px;height:16px;margin-right:5px;'/>");
      parent.click(function(event){
        $(this).toggleClass("ui-state-active");
        parent.toggleClass("ui-icon-radio-off ui-icon-bullet");
        $(element).click();
      });
    },
    selector: function(element){
      // do nothing.
    }
  })
});
