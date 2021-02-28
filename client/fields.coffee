Template.youtube_edit.onRendered ->
    Meteor.setTimeout ->
        $('.ui.embed').embed();
    , 1000

Template.youtube_view.onRendered ->
    Meteor.setTimeout ->
        $('.ui.embed').embed();
    , 1000


Template.youtube_edit.events
    'blur .youtube_id': (e,t)->
        parent = Template.parentData()
        val = t.$('.youtube_id').val()
        doc = Docs.findOne parent._id
        if doc
            Docs.update parent._id,
                $set:"#{@key}":val



Template.color_edit.events
    'blur .edit_color': (e,t)->
        val = t.$('.edit_color').val()
        parent = Template.parentData()
        doc = Docs.findOne parent._id
        if doc
            Docs.update parent._id,
                $set:"#{@key}":val



Template.html_edit.onRendered ->
    @editor = SUNEDITOR.create((document.getElementById('sample') || 'sample'),{
    # 	"tabDisable": false
        # "minHeight": "400px"
        buttonList: [
            [
                'undo' 
                'redo'
                'font' 
                'fontSize' 
                'formatBlock' 
                'paragraphStyle' 
                'blockquote'
                'bold' 
                'underline' 
                'italic' 
                'strike' 
                'subscript' 
                'superscript'
                'fontColor' 
                'hiliteColor' 
                'textStyle'
                'removeFormat'
                'outdent' 
                'indent'
                'align' 
                'horizontalRule' 
                'list' 
                'lineHeight'
                'fullScreen' 
                'showBlocks' 
                'codeView' 
                'preview' 
                'table' 
                'image' 
                'video' 
                'audio' 
                'link'
            ]
        ]
        lang: SUNEDITOR_LANG['en']
        # codeMirror: CodeMirror
    });

Template.html_edit.events
    'blur .testsun': (e,t)->
        html = t.editor.getContents(onlyContents: Boolean);

        parent = Template.parentData()
        doc = Docs.findOne parent._id
        if doc
            Docs.update parent._id,
                $set:"#{@key}":html

    'keyup .testsun': _.throttle((e,t)=>
        html = t.editor.getContents(onlyContents: Boolean);
        # console.log html
        parent = Template.parentData()
        Docs.update parent._id,
            $set:"#{@key}":html
        # $('body').toast({
        #     class: 'success',
        #     message: "saved"
        # })

    , 5000)

Template.html_edit.helpers
        


Template.clear_value.events
    'click .clear_value': ->
        if confirm "clear #{@title} field?"
            parent = Template.parentData()
            doc = Docs.findOne parent._id
            if doc
                Docs.update parent._id,
                    $unset:"#{@key}":1


Template.link_edit.events
    'blur .edit_url': (e,t)->
        val = t.$('.edit_url').val()
        parent = Template.parentData()
        doc = Docs.findOne parent._id
        if doc
            Docs.update parent._id,
                $set:"#{@key}":val


Template.icon_edit.events
    'blur .icon_val': (e,t)->
        val = t.$('.icon_val').val()
        parent = Template.parentData()
        doc = Docs.findOne parent._id
        if doc
            Docs.update parent._id,
                $set:"#{@key}":val

Template.image_link_edit.events
    'blur .image_link_val': (e,t)->
        val = t.$('.image_link_val').val()
        parent = Template.parentData()
        doc = Docs.findOne parent._id
        if doc
            Docs.update parent._id,
                $set:"#{@key}":val


Template.image_edit.events
    "change input[name='upload_image']": (e) ->
        files = e.currentTarget.files
        parent = Template.parentData()
        Cloudinary.upload files[0],
            # folder:"secret" # optional parameters described in http://cloudinary.com/documentation/upload_images#remote_upload
            # model:"private" # optional: makes the image accessible only via a signed url. The signed url is available publicly for 1 hour.
            (err,res) => #optional callback, you can catch with the Cloudinary collection as well
                if err
                    console.error 'Error uploading', err
                else
                    doc = Docs.findOne parent._id
                    if doc
                        Docs.update parent._id,
                            $set:"#{@key}":res.public_id

    'blur .cloudinary_id': (e,t)->
        cloudinary_id = t.$('.cloudinary_id').val()
        parent = Template.parentData()
        Docs.update parent._id,
            $set:"#{@key}":cloudinary_id


    'click #remove_photo': ->
        parent = Template.parentData()

        if confirm 'remove photo?'
            # Docs.update parent._id,
            #     $unset:"#{@key}":1
            doc = Docs.findOne parent._id
            if doc
                Docs.update parent._id,
                    $unset:"#{@key}":1
                    
            




Template.array_edit.events
    # 'click .touch_element': (e,t)->
    #     $(e.currentTarget).closest('.touch_element').transition('slide left')
        
    'click .pick_tag': (e,t)->
        # console.log @
        picked_tags.clear()
        picked_tags.push @valueOf()
        # Router.go "/g/#{Router.current().params.group}"
        Router.go "/"

    'keyup .new_element': (e,t)->
        if e.which is 13
            element_val = t.$('.new_element').val().trim().toLowerCase()
            if element_val.length>0
                parent = Template.parentData()
                doc = Docs.findOne parent._id
                if doc
                    Docs.update parent._id,
                        $addToSet:"#{@key}":element_val
                # window.speechSynthesis.speak new SpeechSynthesisUtterance element_val
                t.$('.new_element').val('')

    'click .remove_element': (e,t)->
        $(e.currentTarget).closest('.touch_element').transition('slide left', 1000)

        element = @valueOf()
        field = Template.currentData()
        parent = Template.parentData()

        doc = Docs.findOne parent._id
        if doc
            Docs.update parent._id,
                $pull:"#{field.key}":element

        t.$('.new_element').focus()
        t.$('.new_element').val(element)

# Template.textarea.onCreated ->
#     @editing = new ReactiveVar false

# Template.textarea.helpers
#     is_editing: -> Template.instance().editing.get()


Template.textarea_edit.events
    # 'click .toggle_edit': (e,t)->
    #     t.editing.set !t.editing.get()

    'blur .edit_textarea': (e,t)->
        textarea_val = t.$('.edit_textarea').val()
        parent = Template.parentData()

        doc = Docs.findOne parent._id
        if doc
            Docs.update parent._id,
                $set:"#{@key}":textarea_val


Template.raw_edit.events
    # 'click .toggle_edit': (e,t)->
    #     t.editing.set !t.editing.get()

    'blur .edit_textarea': (e,t)->
        textarea_val = t.$('.edit_textarea').val()
        parent = Template.parentData()

        doc = Docs.findOne parent._id
        if doc
            Docs.update parent._id,
                $set:"#{@key}":textarea_val



Template.text_edit.events
    'blur .edit_text': (e,t)->
        val = t.$('.edit_text').val()
        parent = Template.parentData()

        doc = Docs.findOne parent._id
        if doc
            Docs.update parent._id,
                $set:"#{@key}":val




Template.textarea_view.onRendered ->
    Meteor.setTimeout ->
        $('.accordion').accordion()
    , 1000



Template.number_edit.events
    'blur .edit_number': (e,t)->
        # console.log @
        parent = Template.parentData()
        val = parseInt t.$('.edit_number').val()
        doc = Docs.findOne parent._id
        if doc
            Docs.update parent._id,
                $set:"#{@key}":val


Template.float_edit.events
    'blur .edit_float': (e,t)->
        parent = Template.parentData()
        val = parseFloat t.$('.edit_float').val()
        doc = Docs.findOne parent._id
        if doc
            Docs.update parent._id,
                $set:"#{@key}":val


Template.boolean_edit.helpers
    boolean_toggle_class: ->
        parent = Template.parentData()
        if parent["#{@key}"] then 'active' else ''


Template.boolean_edit.events
    'click .toggle_boolean': (e,t)->
        parent = Template.parentData()
        # $(e.currentTarget).closest('.button').transition('pulse', 100)

        doc = Docs.findOne parent._id
        if doc
            Docs.update parent._id,
                $set:"#{@key}":!parent["#{@key}"]

