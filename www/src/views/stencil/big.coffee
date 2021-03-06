define [
    "underscore"
    "views/proto/common"
    "models/shared-models", "models/current-user"
    "views/helper/textarea"
    "text!templates/stencil/big.html"
], (_, Common, sharedModels, currentUser, Textarea, html) ->
    class extends Common
        template: _.template html

        events:
            "click .edit": "startEdit"
            "click .post-edit-controls .save": "saveEdit"
            "click .post-edit-controls .cancel": "closeEdit"
            "click .stencil-big-tabs div._icon": "switch"
            "keyup input": "edit"

        switch: (e) ->
            # FIXME - evil, evil copypaste (see also: user/big, realm/tabs)
            t = $(e.target).closest("._icon")
            @tab = t.attr "data-tab"

            @trigger "switch", tab: @tab
            t.closest("ul").find("._active").removeClass "_active"
            t.addClass "_active"

        subviews:
            ".description-sv": ->
                new Textarea
                    realm: @model.get("realm")
                    placeholder: "Stencil description"

        description: -> @subview(".description-sv")

        initialize: ->
            @tab = @options.tab || 'comments'
            super
            @listenTo @model, "change", @render

        render: ->
            # wait for realm data - copy-pasted from views/quest/add
            unless sharedModels.realms.length
                sharedModels.realms.fetch().success => @render()
                return
            super
            @listenTo @description(), "save", @saveEdit
            @listenTo @description(), "cancel", @closeEdit

        serialize: ->
            params = super

            params.currentUser = currentUser.get("login")
            # TODO - move to model.serialize?
            realm = sharedModels.realms.findWhere { id: @model.get("realm") }
            params.isKeeper = realm.isKeeper()
            params.tab = @tab
            params

        startEdit: ->
            @$("._edit").show()
            @$("._editable").hide()
            @$("[name=name]").val @model.get("name")
            @$("[name=name]").focus()
            @validateForm()
            mixpanel.track "start edit", entity: "stencil"
            @description().reveal @model.get("description")

        validateForm: ->
            ok = true
            if @$("[name=name]").val().length
                @$("[name=name]").parent().removeClass "error"
            else
                @$("[name=name]").parent().addClass "error"
                ok = false

            if ok
                @$(".post-edit-controls .save").removeClass "disabled"
            else
                @$(".post-edit-controls .save").addClass "disabled"
            ok

        saveEdit: =>
            # so, we're using DOM data to cache validation status... this is a slippery slope.
            return if @$(".post-edit-controls .save").hasClass("disabled")

            @model.save
                name: @$("[name=name]").val()
                description: @description().value()
                points: @$(".stencil-big-reward .active").attr "data-points"
            @closeEdit()

        edit: (e) ->
            target = $(e.target)
            if @validateForm() and e.which is 13 and target.is("input")
                @saveEdit()
            else if e.which is 27
                @closeEdit()

        closeEdit: =>
            @$("._edit").hide()
            @$("._editable").show()
            @description().hide()

        features: ['timeago', 'tooltip']
