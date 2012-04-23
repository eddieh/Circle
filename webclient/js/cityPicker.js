(function ($) {
  $.fn.extend({
    cityPicker: function (opts) {
      var defaults = {
        'service': 'anyorigin',
        'attachedTo': null
      };
      opts = $.extend(defaults, opts);

      return (this.each(function () {
        var $el = $(this);
        var $locationField = null;
        var options = opts;
        var service = {
          'anyorigin': 'http://anyorigin.com/get/?url=',
          'whateverorigin': 'http://whateverorigin.org/get?url='
        }[options.service];

        var $attachedEl = (typeof(options.attachedTo) == 'string') ?
            $(options.attachedTo) : options.attachedTo;

        $el.click(function (e) {
          $el.hide();
          $locationField = $('<input type="text" />')
              .insertAfter($el)
              .val($el.text())
              .typeahead({
                source: function(typeahead, query) {
                  var url = 'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=' +
                      encodeURIComponent(query)    +
                      '&types=(cities)&sensor=false&key=AIzaSyDi1oeiNkBAo_dNgbJwdcY-usEv-d6FOt4';
                  url = service + encodeURIComponent(url) + '&callback=?';

                  $.getJSON(url, function (data) {
                    var response = (typeof(data.contents) === 'string') ?
                        $.parseJSON(data.contents) : data.contents;
                    typeahead.process(response.predictions);
                  });
                },
                property: 'description',
                onselect: function(val) {
                  var url = 'https://maps.googleapis.com/maps/api/place/details/json?reference=' +
                      val.reference +
                      '&sensor=false&key=AIzaSyDi1oeiNkBAo_dNgbJwdcY-usEv-d6FOt4';                url = service + encodeURIComponent(url) + '&callback=?';

                  $.getJSON(url, function (data) {
                    var response = (typeof(data.contents) === 'string') ?
                        $.parseJSON(data.contents) : data.contents;
                    var result = response.result;

                    $el.trigger('change', result);
                    $locationField.fadeOut(function () {
                      $el.text(result.formatted_address).show();
                      if ($attachedEl) {
                        $attachedEl.focus();
                      }
                    });
                  });
                }
              }).on('blur', function() {
                $locationField.hide();
                $el.show();
                if ($attachedEl) {
                  $attachedEl.focus();
                }
              }).select();
        });
      }));
    }
  });
}(window.jQuery));


