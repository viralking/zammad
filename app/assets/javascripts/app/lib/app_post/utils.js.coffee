class App.Utils

  # textCleand = App.Utils.textCleanup( rawText )
  @textCleanup: ( ascii ) ->
    $.trim( ascii )
      .replace(/(\r\n|\n\r)/g, "\n")  # cleanup
      .replace(/\r/g, "\n")           # cleanup
      .replace(/[ ]\n/g, "\n")        # remove tailing spaces
      .replace(/\n{3,9}/g, "\n\n")    # remove multible empty lines

  # htmlEscapedAndLinkified = App.Utils.text2html( rawText )
  @text2html: ( ascii ) ->
    ascii = @textCleanup(ascii)
    #ascii = @htmlEscape(ascii)
    ascii = @linkify(ascii)
    ascii = '<div>' + ascii.replace(/\n/g, '</div><div>') + '</div>'
    ascii.replace(/<div><\/div>/g, '<div><br></div>')

  # htmlEscapedAndLinkified = App.Utils.linkify( rawText )
  @linkify: (ascii) ->
    window.linkify( ascii )

  # wrappedText = App.Utils.wrap( rawText, maxLineLength )
  @wrap: (ascii, max = 82) ->
    result        = ''
    counter_lines = 0
    lines         = ascii.split(/\n/)
    for line in lines
      counter_lines += 1
      counter_parts  = 0
      part_length    = 0
      result_part    = ''
      parts          = line.split(/\s/)
      for part in parts
        counter_parts += 1

        # put overflow of parts to result and start new line
        if (part_length + part.length) > max
          part_length = 0
          result_part = result_part.trim()
          result_part += "\n"
          result     += result_part
          result_part = ''

        part_length += part.length
        result_part += part

        # add spacer at the end
        if counter_parts isnt parts.length
          part_length += 1
          result_part += ' '

      # put parts to result
      result     += result_part
      result_part = ''

      # add new line
      if counter_lines isnt lines.length
        result += "\n"
    result

  # quotedText = App.Utils.quote( rawText )
  @quote: (ascii, max = 82) ->
    ascii = @textCleanup(ascii)
    ascii = @wrap(ascii, max)
    $.trim( ascii )
      .replace /^(.*)$/mg, (match) =>
        if match
          '> ' + match
        else
          '>'

  # htmlEscaped = App.Utils.htmlEscape( rawText )
  @htmlEscape: ( ascii ) ->
    ascii.replace(/&/g, '&amp;')
      .replace(/</g, '&lt;')
      .replace(/>/g, '&gt;')
      .replace(/"/g, '&quot;')
      .replace(/'/g, '&#39;')

  # textWithoutTags = App.Utils.htmlRemoveTags( html )
  @htmlRemoveTags: (html) ->

    # remove tags, keep content
    html.find('div, span, p, li, ul, ol, a, b, u, i, label, small, strong, strike, pre, code, center, blockquote, form, textarea, font, address, table, thead, tbody, tr, td, h1, h2, h3, h4, h5, h6').replaceWith( ->
      $(@).contents()
    )

    # remove tags & content
    html.find('div, span, p, li, ul, ol, a, b, u, i, label, small, strong, strike, pre, code, center, blockquote, form, textarea, font, table, thead, tbody, tr, td, h1, h2, h3, h4, h5, h6, br, hr, img, input, select, button, style, applet, canvas, script, frame, iframe').remove()

    html

  # htmlOnlyWithRichtext = App.Utils.htmlRemoveRichtext( html )
  @htmlRemoveRichtext: (html) ->

    # remove style and class
    @_removeAttributes( html )

    # remove tags, keep content
    html.find('li, ul, ol, a, b, u, i, label, small, strong, strike, pre, code, center, blockquote, form, textarea, font, address, table, thead, tbody, tr, td, h1, h2, h3, h4, h5, h6').replaceWith( ->
      $(@).contents()
    )

    # remove tags & content
    html.find('li, ul, ol, a, b, u, i, label, small, strong, strike, pre, code, center, blockquote, form, textarea, font, address, table, thead, tbody, tr, td, h1, h2, h3, h4, h5, h6, hr, img, input, select, button, style, applet, canvas, script, frame, iframe').remove()

    html

  # cleanHtmlWithRichText = App.Utils.htmlCleanup( html )
  @htmlCleanup: (html) ->

    # remove style and class
    @_removeAttributes( html )

    # remove tags, keep content
    html.find('a, font, small, time').replaceWith( ->
      $(@).contents()
    )

    # replace tags with generic div
    # New type of the tag
    replacementTag = 'div';

    # Replace all a tags with the type of replacementTag
    html.find('h1, h2, h3, h4, h5, h6, textarea').each( ->
      outer = this.outerHTML;

      # Replace opening tag
      regex = new RegExp('<' + this.tagName, 'i');
      newTag = outer.replace(regex, '<' + replacementTag);

      # Replace closing tag
      regex = new RegExp('</' + this.tagName, 'i');
      newTag = newTag.replace(regex, '</' + replacementTag);

      $(@).replaceWith(newTag);
    )

    # remove tags & content
    html.find('form, font, hr, img, input, select, button, style, applet, canvas, script, frame, iframe').remove()

    html

  @_removeAttributes: (html) ->
    html.find('div, span, p, li, ul, ol, a, b, u, i, label, small, strong, strike, pre, code, center, blockquote, h1, h2, h3, h4, h5, h6')
      .removeAttr( 'style' )
      .removeAttr( 'class' )
      .removeAttr( 'title' )
    html

  # signatureNeeded = App.Utils.signatureCheck( message, signature )
  @signatureCheck: (message, signature) ->
    messageText   = $( '<div>' + message + '</div>' ).text().trim()
    messageText   = messageText.replace(/(\n|\r|\t)/g, '')
    signatureText = $( '<div>' + signature + '</div>' ).text().trim()
    signatureText = signatureText.replace(/(\n|\r|\t)/g, '')

    quote = (str) ->
      (str + '').replace(/[.?*+^$[\]\\(){}|-]/g, "\\$&")

    #console.log('SC', messageText, signatureText, quote(signatureText))
    regex = new RegExp( quote(signatureText), 'mi' )
    if messageText.match(regex)
      false
    else
      true

  # textReplaced = App.Utils.replaceTags( template, { user: { firstname: 'Bob', lastname: 'Smith' } } )
  @replaceTags: (template, objects) ->
    template = template.replace( /#\{\s{0,2}(.+?)\s{0,2}\}/g, ( index, key ) ->
      levels  = key.split(/\./)
      dataRef = objects
      for level in levels
        if dataRef[level]
          dataRef = dataRef[level]
      if typeof dataRef is 'function'
        value = dataRef()
      else if typeof dataRef is 'string'
        value = dataRef
      else
        value = ''
      #console.log( "tag replacement #{key}, #{value} env: ", objects)
      value
    )

  # true|false = App.Utils.lastLineEmpty( message )
  @lastLineEmpty: (message) ->
    messageCleanup = message.replace(/>\s+</g, '><').replace(/(\n|\r|\t)/g, '').trim()
    return true if messageCleanup.match(/<(br|\s+?|\/)>$/im)
    return true if messageCleanup.match(/<div(|\s.+?)><\/div>$/im)
    false

  # cleanString = App.Utils.htmlAttributeCleanup( string )
  @htmlAttributeCleanup: (string) ->
    string.replace(/((?![-a-zA-Z0-9_]+).|\n|\r|\t)/gm, '')

  # diff = App.Utils.formDiff( dataNow, dataLast )
  @formDiff: ( dataNowRaw, dataLastRaw ) ->

    # do type convertation to compare it against form
    dataNow = clone(dataNowRaw)
    @_formDiffNormalizer(dataNow)
    dataLast = clone(dataLastRaw)
    @_formDiffNormalizer(dataLast)

    @_formDiffChanges( dataNow, dataLast )

  @_formDiffChanges: (dataNow, dataLast, changes = {}) ->
    for dataNowkey, dataNowValue of dataNow
      if dataNow[dataNowkey] isnt dataLast[dataNowkey]
        if _.isArray( dataNow[dataNowkey] ) && _.isArray( dataLast[dataNowkey] )
          diff = _.difference( dataNow[dataNowkey], dataLast[dataNowkey] )
          if !_.isEmpty( diff )
            changes[dataNowkey] = diff
        else if _.isObject( dataNow[dataNowkey] ) &&  _.isObject( dataLast[dataNowkey] )
          changes = @_formDiffChanges( dataNow[dataNowkey], dataLast[dataNowkey], changes )
        else
          changes[dataNowkey] = dataNow[dataNowkey]
    changes

  @_formDiffNormalizer: (data) ->
    if _.isArray( data )
      for i in [0...data.length]
        data[i] = @_formDiffNormalizer( data[i] )
    else if _.isObject( data )
      for key, value of data

        if _.isArray( data[key] )
          @_formDiffNormalizer( data[key] )
        else if _.isObject( data[key] )
          @_formDiffNormalizer( data[key] )
        else
          data[key] = @_formDiffNormalizerItem( key, data[key] )
    else
      @_formDiffNormalizerItem( '', data )


  @_formDiffNormalizerItem: (key, value) ->

    # handel owner/nobody behavior
    if key is 'owner_id' && value.toString() is '1'
      value = ''
    else if typeof value is 'number'
      value = value.toString()

    # handle null/undefined behavior - we just handle both as the same
    else if value is null
      value = undefined

    value
