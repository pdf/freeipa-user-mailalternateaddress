define(
  [
    'freeipa/phases',
    'freeipa/user'
  ],
  function(phases, user_mod) {

    // helper function
    function get_item(array, attr, value) {
      for (var i=0, l=array.length; i < l; i++) {
        if (array[i][attr] === value) {
          return array[i];
        }
      }
      return null;
    }

    var user_mail_alt_plugin = {};

    // adds 'mailalternateaddress' field into user details facet
    user_mail_alt_plugin.add_mail_alt_pre_op = function() {
      var facet = get_item(user_mod.entity_spec.facets, '$type', 'details');
      if (facet !== null) {
        var section = get_item(facet.sections, 'name', 'contact');
        if (section !== null) {
          section.fields.push(
            { $type: 'multivalued', name: 'mailalternateaddress' }
          )
        }
      }
      return true;
    };

    phases.on('customization', user_mail_alt_plugin.add_mail_alt_pre_op);

    return user_mail_alt_plugin;
  }
);
