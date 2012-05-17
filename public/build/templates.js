
var jade = (function(exports){
/*!
 * Jade - runtime
 * Copyright(c) 2010 TJ Holowaychuk <tj@vision-media.ca>
 * MIT Licensed
 */

/**
 * Lame Array.isArray() polyfill for now.
 */

if (!Array.isArray) {
  Array.isArray = function(arr){
    return '[object Array]' == Object.prototype.toString.call(arr);
  };
}

/**
 * Lame Object.keys() polyfill for now.
 */

if (!Object.keys) {
  Object.keys = function(obj){
    var arr = [];
    for (var key in obj) {
      if (obj.hasOwnProperty(key)) {
        arr.push(key);
      }
    }
    return arr;
  } 
}

/**
 * Render the given attributes object.
 *
 * @param {Object} obj
 * @param {Object} escaped
 * @return {String}
 * @api private
 */

exports.attrs = function attrs(obj, escaped){
  var buf = []
    , terse = obj.terse;

  delete obj.terse;
  var keys = Object.keys(obj)
    , len = keys.length;

  if (len) {
    buf.push('');
    for (var i = 0; i < len; ++i) {
      var key = keys[i]
        , val = obj[key];

      if ('boolean' == typeof val || null == val) {
        if (val) {
          terse
            ? buf.push(key)
            : buf.push(key + '="' + key + '"');
        }
      } else if (0 == key.indexOf('data') && 'string' != typeof val) {
        buf.push(key + "='" + JSON.stringify(val) + "'");
      } else if ('class' == key && Array.isArray(val)) {
        buf.push(key + '="' + exports.escape(val.join(' ')) + '"');
      } else if (escaped[key]) {
        buf.push(key + '="' + exports.escape(val) + '"');
      } else {
        buf.push(key + '="' + val + '"');
      }
    }
  }

  return buf.join(' ');
};

/**
 * Escape the given string of `html`.
 *
 * @param {String} html
 * @return {String}
 * @api private
 */

exports.escape = function escape(html){
  return String(html)
    .replace(/&(?!\w+;)/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;');
};

/**
 * Re-throw the given `err` in context to the
 * the jade in `filename` at the given `lineno`.
 *
 * @param {Error} err
 * @param {String} filename
 * @param {String} lineno
 * @api private
 */

exports.rethrow = function rethrow(err, filename, lineno){
  if (!filename) throw err;

  var context = 3
    , str = require('fs').readFileSync(filename, 'utf8')
    , lines = str.split('\n')
    , start = Math.max(lineno - context, 0)
    , end = Math.min(lines.length, lineno + context); 

  // Error context
  var context = lines.slice(start, end).map(function(line, i){
    var curr = i + start + 1;
    return (curr == lineno ? '  > ' : '    ')
      + curr
      + '| '
      + line;
  }).join('\n');

  // Alter exception message
  err.path = filename;
  err.message = (filename || 'Jade') + ':' + lineno 
    + '\n' + context + '\n\n' + err.message;
  throw err;
};

  return exports;

})({});
jade.templates = {};
jade.render = function(node, template, data) {
  var tmp = jade.templates[template](data);
  node.innerHTML = tmp;
};

jade.templates["card"] = function(locals, attrs, escape, rethrow) {
var attrs = jade.attrs, escape = jade.escape, rethrow = jade.rethrow;
var buf = [];
with (locals || {}) {
var interp;
buf.push('<div');
buf.push(attrs({ "class": ('card') + ' ' + ('card-single') + ' ' + ('card-show') }, {}));
buf.push('><div');
buf.push(attrs({ "class": ('card-content') }, {}));
buf.push('><div');
buf.push(attrs({ "class": ('card-main') }, {}));
buf.push('><div');
buf.push(attrs({ "class": ('name') }, {}));
buf.push('>' + escape((interp = name) == null ? '' : interp) + '</div><div');
buf.push(attrs({ "class": ('address') }, {}));
buf.push('>' + escape((interp = address) == null ? '' : interp) + '</div><div');
buf.push(attrs({ "class": ('notes') }, {}));
buf.push('>' + escape((interp = notes) == null ? '' : interp) + '</div></div><div');
buf.push(attrs({ "class": ('card-footer') + ' ' + ('group') }, {}));
buf.push('><div');
buf.push(attrs({ "class": ('city') }, {}));
buf.push('>' + escape((interp = city) == null ? '' : interp) + '</div></div></div></div>');
}
return buf.join("");
}
jade.templates["cardedit"] = function(locals, attrs, escape, rethrow) {
var attrs = jade.attrs, escape = jade.escape, rethrow = jade.rethrow;
var buf = [];
with (locals || {}) {
var interp;
buf.push('<div');
buf.push(attrs({ "class": ('card') + ' ' + ('card-single') + ' ' + ('card-edit') }, {}));
buf.push('><div');
buf.push(attrs({ "class": ('card-content') }, {}));
buf.push('><form><label>Name</label><input');
buf.push(attrs({ 'name':('name'), 'type':('text'), 'value':('' + (name) + '') }, {"name":true,"type":true,"value":true}));
buf.push('/><label>Address</label><input');
buf.push(attrs({ 'name':('address'), 'type':('text'), 'value':('' + (address) + '') }, {"name":true,"type":true,"value":true}));
buf.push('/><label>City</label><input');
buf.push(attrs({ 'name':('city'), 'type':('text'), 'value':('' + (city) + '') }, {"name":true,"type":true,"value":true}));
buf.push('/><label>Notes</label><textarea');
buf.push(attrs({ 'name':('notes') }, {"name":true}));
buf.push('>' + escape((interp = notes) == null ? '' : interp) + '</textarea><div');
buf.push(attrs({ "class": ('form-actions-inline') }, {}));
buf.push('><button');
buf.push(attrs({ "class": ('btn') + ' ' + ('js-save') }, {}));
buf.push('>Save</button><button');
buf.push(attrs({ "class": ('btn') + ' ' + ('js-cancel') }, {}));
buf.push('>Cancel</button></div></form></div></div>');
}
return buf.join("");
}
jade.templates["cards"] = function(locals, attrs, escape, rethrow) {
var attrs = jade.attrs, escape = jade.escape, rethrow = jade.rethrow;
var buf = [];
with (locals || {}) {
var interp;
buf.push('<div');
buf.push(attrs({ "class": ('container') }, {}));
buf.push('><div');
buf.push(attrs({ 'id':('js-nocards'), 'style':('display: none; '), "class": ('nocards') }, {"style":true}));
buf.push('>Click on \'New\' to add new cards.</div><div');
buf.push(attrs({ "class": ('cards-wrapper') }, {}));
buf.push('><ol');
buf.push(attrs({ 'id':('js-cardslist'), "class": ('cards') + ' ' + ('group') }, {}));
buf.push('></ol></div></div>');
}
return buf.join("");
}
jade.templates["cardshare"] = function(locals, attrs, escape, rethrow) {
var attrs = jade.attrs, escape = jade.escape, rethrow = jade.rethrow;
var buf = [];
with (locals || {}) {
var interp;
buf.push('<div');
buf.push(attrs({ "class": ('card') + ' ' + ('card-single') + ' ' + ('card-other') }, {}));
buf.push('><div');
buf.push(attrs({ "class": ('card-content') }, {}));
buf.push('><h2>' + escape((interp = name) == null ? '' : interp) + '</h2><div');
buf.push(attrs({ "class": ('info') }, {}));
buf.push('>Send this link to your friends and family to share this card:</div><form><input');
buf.push(attrs({ 'name':('link'), 'type':('text'), 'value':('' + (link) + '') }, {"name":true,"type":true,"value":true}));
buf.push('/></form></div></div>');
}
return buf.join("");
}
jade.templates["cardsmall"] = function(locals, attrs, escape, rethrow) {
var attrs = jade.attrs, escape = jade.escape, rethrow = jade.rethrow;
var buf = [];
with (locals || {}) {
var interp;
buf.push('<div');
buf.push(attrs({ "class": ('card') + ' ' + ('card-small') }, {}));
buf.push('><a');
buf.push(attrs({ 'href':('/card/' + (_id) + ''), "class": ('card-link') + ' ' + ('js-show') }, {"href":true}));
buf.push('><div');
buf.push(attrs({ "class": ('card-content') }, {}));
buf.push('><div');
buf.push(attrs({ "class": ('card-main') }, {}));
buf.push('><div');
buf.push(attrs({ "class": ('name') }, {}));
buf.push('>' + escape((interp = name) == null ? '' : interp) + '</div><div');
buf.push(attrs({ "class": ('address') }, {}));
buf.push('>' + escape((interp = address) == null ? '' : interp) + ' </div><div');
buf.push(attrs({ "class": ('notes') }, {}));
buf.push('>' + escape((interp = notes) == null ? '' : interp) + '</div></div><div');
buf.push(attrs({ "class": ('card-footer') + ' ' + ('group') }, {}));
buf.push('><div');
buf.push(attrs({ "class": ('city') }, {}));
buf.push('>' + escape((interp = city) == null ? '' : interp) + '</div></div></div></a></div>');
}
return buf.join("");
}
jade.templates["cardsnew"] = function(locals, attrs, escape, rethrow) {
var attrs = jade.attrs, escape = jade.escape, rethrow = jade.rethrow;
var buf = [];
with (locals || {}) {
var interp;
buf.push('<div');
buf.push(attrs({ "class": ('card') + ' ' + ('card-single') + ' ' + ('card-new') }, {}));
buf.push('><div');
buf.push(attrs({ "class": ('card-content') }, {}));
buf.push('><form><label>Name</label><input');
buf.push(attrs({ 'name':('name'), 'type':('text'), 'placeholder':('ex: The Dead Poet') }, {"name":true,"type":true,"placeholder":true}));
buf.push('/><label>Address</label><input');
buf.push(attrs({ 'name':('address'), 'type':('text'), 'placeholder':('ex: 450 Amsterdam Ave (& 81st St)') }, {"name":true,"type":true,"placeholder":true}));
buf.push('/><label>City</label><input');
buf.push(attrs({ 'name':('city'), 'type':('text'), 'placeholder':('ex: New York') }, {"name":true,"type":true,"placeholder":true}));
buf.push('/><label>Notes</label><textarea');
buf.push(attrs({ 'name':('notes'), 'placeholder':('ex: Irish pub, small room, good beer, nice decoration, jukebox') }, {"name":true,"placeholder":true}));
buf.push('></textarea><div');
buf.push(attrs({ "class": ('form-actions-inline') }, {}));
buf.push('><button');
buf.push(attrs({ "class": ('btn') + ' ' + ('js-add') }, {}));
buf.push('>Add</button><button');
buf.push(attrs({ "class": ('btn') + ' ' + ('js-cancel') }, {}));
buf.push('>Cancel</button></div></form></div></div>');
}
return buf.join("");
}
jade.templates["cardsshare"] = function(locals, attrs, escape, rethrow) {
var attrs = jade.attrs, escape = jade.escape, rethrow = jade.rethrow;
var buf = [];
with (locals || {}) {
var interp;
buf.push('<div');
buf.push(attrs({ "class": ('card') + ' ' + ('card-single') + ' ' + ('card-other') }, {}));
buf.push('><div');
buf.push(attrs({ "class": ('card-content') }, {}));
buf.push('><h2>Cards</h2><div');
buf.push(attrs({ "class": ('info') }, {}));
buf.push('>Send this link to your friends and family to share your cards:</div><form><input');
buf.push(attrs({ 'name':('link'), 'type':('text'), 'value':('' + (link) + '') }, {"name":true,"type":true,"value":true}));
buf.push('/></form></div></div>');
}
return buf.join("");
}
jade.templates["navigation"] = function(locals, attrs, escape, rethrow) {
var attrs = jade.attrs, escape = jade.escape, rethrow = jade.rethrow;
var buf = [];
with (locals || {}) {
var interp;
buf.push('<div');
buf.push(attrs({ "class": ('navbar') }, {}));
buf.push('><div');
buf.push(attrs({ "class": ('container') }, {}));
buf.push('><div');
buf.push(attrs({ "class": ('navbar-inner') + ' ' + ('group') }, {}));
buf.push('><div');
buf.push(attrs({ "class": ('logo') + ' ' + ('js-home') }, {}));
buf.push('><a');
buf.push(attrs({ 'href':('/home') }, {"href":true}));
buf.push('>Outfolio</a></div>');
if ( authenticated)
{
buf.push('<ul');
buf.push(attrs({ "class": ('nav') }, {}));
buf.push('><li');
buf.push(attrs({ "class": ('js-cards') }, {}));
buf.push('><a');
buf.push(attrs({ 'href':('/cards') }, {"href":true}));
buf.push('>Cards</a></li></ul><ul');
buf.push(attrs({ "class": ('nav') + ' ' + ('nav-right') }, {}));
buf.push('><li>' + escape((interp = user.name) == null ? '' : interp) + '</li><li');
buf.push(attrs({ "class": ('js-sign-out') }, {}));
buf.push('><a');
buf.push(attrs({ 'href':('/logout') }, {"href":true}));
buf.push('>Sign out</a></li></ul>');
}
else
{
buf.push('<ul');
buf.push(attrs({ "class": ('nav') + ' ' + ('nav-right') }, {}));
buf.push('><li');
buf.push(attrs({ "class": ('js-sign-in') }, {}));
buf.push('><a');
buf.push(attrs({ 'href':('/login') }, {"href":true}));
buf.push('>Sign in</a></li></ul>');
}
buf.push('</div></div></div>');
}
return buf.join("");
}
jade.templates["notifications"] = function(locals, attrs, escape, rethrow) {
var attrs = jade.attrs, escape = jade.escape, rethrow = jade.rethrow;
var buf = [];
with (locals || {}) {
var interp;
if ( notification)
{
buf.push('<div');
buf.push(attrs({ "class": ('container') }, {}));
buf.push('><div');
buf.push(attrs({ "class": ('notifications') }, {}));
buf.push('><span');
buf.push(attrs({ "class": ('' + (notification.type) + '') + ' ' + ('notification') }, {}));
buf.push('>' + ((interp = notification.message) == null ? '' : interp) + '</span></div></div>');
}
}
return buf.join("");
}
jade.templates["sharedcards"] = function(locals, attrs, escape, rethrow) {
var attrs = jade.attrs, escape = jade.escape, rethrow = jade.rethrow;
var buf = [];
with (locals || {}) {
var interp;
buf.push('<div');
buf.push(attrs({ "class": ('container') }, {}));
buf.push('><div');
buf.push(attrs({ 'id':('js-nocards'), 'style':('display: none; '), "class": ('nocards') }, {"style":true}));
buf.push('>This user has no cards yet.</div><div');
buf.push(attrs({ "class": ('cards-wrapper') }, {}));
buf.push('><ol');
buf.push(attrs({ 'id':('js-cardslist'), "class": ('cards') + ' ' + ('group') }, {}));
buf.push('></ol></div></div>');
}
return buf.join("");
}
jade.templates["sharedcardsmall"] = function(locals, attrs, escape, rethrow) {
var attrs = jade.attrs, escape = jade.escape, rethrow = jade.rethrow;
var buf = [];
with (locals || {}) {
var interp;
buf.push('<div');
buf.push(attrs({ "class": ('card') + ' ' + ('card-small') }, {}));
buf.push('><a');
buf.push(attrs({ 'href':('/shared/' + (owner._id) + '/card/' + (_id) + ''), "class": ('card-link') + ' ' + ('js-show') }, {"href":true}));
buf.push('><div');
buf.push(attrs({ "class": ('card-content') }, {}));
buf.push('><div');
buf.push(attrs({ "class": ('card-main') }, {}));
buf.push('><div');
buf.push(attrs({ "class": ('name') }, {}));
buf.push('>' + escape((interp = name) == null ? '' : interp) + '</div><div');
buf.push(attrs({ "class": ('address') }, {}));
buf.push('>' + escape((interp = address) == null ? '' : interp) + ' </div><div');
buf.push(attrs({ "class": ('notes') }, {}));
buf.push('>' + escape((interp = notes) == null ? '' : interp) + '</div></div><div');
buf.push(attrs({ "class": ('card-footer') + ' ' + ('group') }, {}));
buf.push('><div');
buf.push(attrs({ "class": ('city') }, {}));
buf.push('>' + escape((interp = city) == null ? '' : interp) + '</div></div></div></a></div>');
}
return buf.join("");
}
jade.templates["subnavcards"] = function(locals, attrs, escape, rethrow) {
var attrs = jade.attrs, escape = jade.escape, rethrow = jade.rethrow;
var buf = [];
with (locals || {}) {
var interp;
buf.push('<div');
buf.push(attrs({ "class": ('container') }, {}));
buf.push('><div');
buf.push(attrs({ "class": ('subnavbar') + ' ' + ('group') }, {}));
buf.push('><ul');
buf.push(attrs({ "class": ('subnav') }, {}));
buf.push('>');
if ( authenticated)
{
buf.push('<li');
buf.push(attrs({ "class": ('js-cards') }, {}));
buf.push('><a');
buf.push(attrs({ 'href':('/cards') }, {"href":true}));
buf.push('>Cards</a></li>');
}
if ( owner)
{
buf.push('<li');
buf.push(attrs({ "class": ('js-shared') }, {}));
buf.push('> <a');
buf.push(attrs({ 'href':('/shared/' + (owner._id) + '') }, {"href":true}));
buf.push('>' + escape((interp = owner.name) == null ? '' : interp) + '</a></li>');
}
buf.push('</ul><ul');
buf.push(attrs({ "class": ('subnav') + ' ' + ('subnav-right') }, {}));
buf.push('>');
if ( !owner && authenticated)
{
if ( card)
{
buf.push('<li');
buf.push(attrs({ "class": ('js-card') }, {}));
buf.push('><a');
buf.push(attrs({ 'href':('/card/' + (card._id) + '') }, {"href":true}));
buf.push('>Card</a></li><li');
buf.push(attrs({ "class": ('js-edit') }, {}));
buf.push('><a');
buf.push(attrs({ 'href':('/card/' + (card._id) + '/edit') }, {"href":true}));
buf.push('>Edit</a></li><li');
buf.push(attrs({ "class": ('js-card-share') }, {}));
buf.push('><a');
buf.push(attrs({ 'href':('/card/' + (card._id) + '/share') }, {"href":true}));
buf.push('>Share</a></li><li');
buf.push(attrs({ "class": ('js-delete') }, {}));
buf.push('><a');
buf.push(attrs({ 'href':('#') }, {"href":true}));
buf.push('>Delete</a></li>');
}
else
{
buf.push('<li');
buf.push(attrs({ "class": ('js-new') }, {}));
buf.push('><a');
buf.push(attrs({ 'href':('/cards/new') }, {"href":true}));
buf.push('>New</a></li><li');
buf.push(attrs({ "class": ('js-share') }, {}));
buf.push('><a');
buf.push(attrs({ 'href':('/cards/share') }, {"href":true}));
buf.push('>Share</a></li><li');
buf.push(attrs({ "class": ('js-refresh') }, {}));
buf.push('><a');
buf.push(attrs({ 'href':('#') }, {"href":true}));
buf.push('>Refresh</a></li>');
}
}
else if ( owner && card)
{
buf.push('<li');
buf.push(attrs({ "class": ('js-shared-card') }, {}));
buf.push('><a');
buf.push(attrs({ 'href':('/shared/' + (owner._id) + '/card/' + (card._id) + '') }, {"href":true}));
buf.push('>Card</a></li>');
}
else
{
buf.push('<li');
buf.push(attrs({ "class": ('js-refresh') }, {}));
buf.push('><a');
buf.push(attrs({ 'href':('#') }, {"href":true}));
buf.push('>Refresh</a></li>');
}
buf.push('</ul></div></div>');
}
return buf.join("");
}