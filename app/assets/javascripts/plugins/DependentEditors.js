/*
 * 
 */
;(function(Form) {

/*
 * 
 */
_.extend(Form.Editor.prototype, {
    dependsOnChanged : function(form, editor, extra) {
        var groupElement = this.$el.parents('.control-group');
        this.setInitValue(groupElement, editor.getValue(), this.options.schema.dependentValues);
    },

    setInitValue : function(element, value, expectedValues) {
        if ( ( value != null) && ($.inArray(value.toString(), expectedValues) > -1) ) {
            element.removeClass('hidden-form-group');
        } else {
            element.addClass('hidden-form-group');
        }
    },

    dependInit : function(form) {
            _.defer( function(editor, el, dependsOn, expectedValues) {
                var intialDependantValue = null;
                var cid = null;
                if ((typeof editor.form.model != 'undefined') && (editor.form.model != null)) {
                    intialDependantValue = editor.form.model.get(dependsOn);
                    cid = editor.form.model.cid;
                } else if ((typeof editor.form.data != 'undefined') && (editor.form.data != null)) {
                    intialDependantValue = editor.form.data[dependsOn];
                    cid = editor.cid;
                };
                
                var groupElement = el.parents('.control-group');
                editor.setInitValue(groupElement, intialDependantValue, expectedValues);
            }, this, this.$el, this.options.schema.dependsOn, this.options.schema.dependentValues );
    }
});

/*
 *
 */
Form.editors.DependentText = Form.editors.TextArea.extend({

    render: function() {
        this.form.on(this.options.schema.dependsOn + ':change', this.dependsOnChanged, this );
       
        this.setValue(this.value);

        this.dependInit(this.form);

        return this;
    }

});

Form.editors.DependentCheckbox = Form.editors.Checkbox.extend({

    render: function() {
        this.form.on(this.options.schema.dependsOn + ':change', this.dependsOnChanged, this );
       
        this.setValue(this.value);

        this.dependInit(this.form);
        
        return this;
    }

});

Form.editors.DependentSelect = Form.editors.Select.extend({

    render: function() {
        this.form.on(this.options.schema.dependsOn + ':change', this.dependsOnChanged, this );
       
        this.setOptions(this.schema.options);
        
        this.dependInit(this.form);
        
        return this;
    }

});

Form.editors.DependentCheckboxes = Form.editors.Checkboxes.extend({

    render: function() {
        this.form.on(this.options.schema.dependsOn + ':change', this.dependsOnChanged, this );
       
        this.setValue(this.value);

        this.dependInit(this.form);
        
        return this;
    }

});

Form.editors.DependentNumber = Form.editors.Number.extend({

    render: function() {
        this.form.on(this.options.schema.dependsOn + ':change', this.dependsOnChanged, this );
       
        this.setValue(this.value);

        this.dependInit(this.form);
        
        return this;
    }

});

Form.editors.DependentTime = Form.editors.Time.extend({
    render: function() {
        this.form.on(this.options.schema.dependsOn + ':change', this.dependsOnChanged, this );
        var options = this.options,
            schema = this.schema;

        // Set the time options - set this to units of 15
        var timeOptions = _.map(_.range(0,60, schema.minsInterval), function(time) {
            return '<option value="'+time+'">' + time + '</option>';
        });
        var hourOptions = _.map(_.range(0,23, 1), function(hour) {
            return '<option value="'+hour+'">' + hour + '</option>';
        });
        
        var $el = $($.trim(this.template({
            hours: hourOptions.join(''),
            times: timeOptions.join(''),
            })));
            
        this.$time = $el.find('[data-type="time"]');
        this.$hour = $el.find('[data-type="hour"]');
        
        this.setValue(this.value);
        
        this.setElement($el);
        this.$el.attr('id', this.id);
        this.$el.attr('name', this.getName());

        if (this.hasFocus) this.trigger('blur', this);
        
        this.dependInit(this.form);
        
        return this;
    },
});

Form.editors.DependentList = Form.editors.List.extend({

    render: function() {
        this.form.on(this.options.schema.dependsOn + ':change', this.dependsOnChanged, this );
        var self = this,
            value = this.value || [];

        //Create main element
        var $el = $($.trim(this.template()));

        //Store a reference to the list (item container)
        this.$list = $el.is('[data-items]') ? $el : $el.find('[data-items]');

        //Add existing items
        if (value.length) {
            _.each(value, function(itemValue) {
            self.addItem(itemValue);
            });
        }

        //If no existing items create an empty one, unless the editor specifies otherwise
        else {
            if (!this.Editor.isAsync) this.addItem();
        }

        this.setElement($el);
        this.$el.attr('id', this.id);
        this.$el.attr('name', this.key);
            
        if (this.hasFocus) this.trigger('blur', this);
      
        this.dependInit(this.form);
            
        return this;
    }
});

/*
 * 
 */

})(Backbone.Form);