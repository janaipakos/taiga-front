class AttachmentsController
    @.$inject = [
        "tgAttachmentsService"
    ]

    constructor: (@attachmentsService) ->
        @.deprecatedsVisible = false
        @.maxFileSize = @attachmentsService.maxFileSize
        @.maxFileSizeFormated = @attachmentsService.maxFileSizeFormated

    generate: () ->
        @.deprecatedsCount = @.attachmentsAll.count (it) -> it.get('is_deprecated')

        if @.deprecatedsVisible
            @.attachments = @.attachmentsAll
        else
            @.attachments = @.attachmentsAll.filterNot (it) -> it.get('is_deprecated')

    toggleDeprecatedsVisible: () ->
        @.deprecatedsVisible = !@.deprecatedsVisible
        @.generate()

    addAttachment: (file) ->
        attachment = Immutable.fromJS({
            file: file,
            name: file.name,
            size: file.size
        })

        if @attachmentsService.validate(file)
            @.attachmentsAll = @.attachmentsAll.push(attachment)

    addAttachments: (files) ->
        _.forEach files, @.addAttachment.bind(this)

    deleteAttachment: (toDeleteAttachment) ->
        @.attachmentsAll = @.attachmentsAll.filter (attachment) -> attachment != toDeleteAttachment

    reorderAttachment: (attachment, newIndex) ->
        oldIndex = @.attachmentsAll.findIndex (it) -> it == attachment
        return if oldIndex == newIndex

        @.attachmentsAll = @.attachmentsAll.remove(oldIndex)
        @.attachmentsAll = @.attachmentsAll.splice(newIndex, 0, attachment)

        @.attachmentsAll = @.attachmentsAll.map (x, i) -> x.set('order', i + 1)

    updateAttachment: (toUpdateAttachment) ->
        index = @.attachmentsAll.findIndex (attachment) ->
            return attachment.get('id') == toUpdateAttachment.get('id')

        @.attachmentsAll = @.attachmentsAll.update index, () -> toUpdateAttachment

angular.module("taigaComponents").controller("Attachments", AttachmentsController)
