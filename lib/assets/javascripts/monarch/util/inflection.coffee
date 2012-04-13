rules =
  plural:  [
    [/(quiz)$/i,               "$1zes"  ]
    [/^(ox)$/i,                "$1en"   ]
    [/([m|l])ouse$/i,          "$1ice"  ]
    [/(matr|vert|ind)ix|ex$/i, "$1ices" ]
    [/(x|ch|ss|sh)$/i,         "$1es"   ]
    [/([^aeiouy]|qu)y$/i,      "$1ies"  ]
    [/(hive)$/i,               "$1s"    ]
    [/(?:([^f])fe|([lr])f)$/i, "$1$2ves"]
    [/sis$/i,                  "ses"    ]
    [/([ti])um$/i,             "$1a"    ]
    [/(buffal|tomat)o$/i,      "$1oes"  ]
    [/(bu)s$/i,                "$1ses"  ]
    [/(alias|status)$/i,       "$1es"   ]
    [/(octop|vir)us$/i,        "$1i"    ]
    [/(ax|test)is$/i,          "$1es"   ]
    [/s$/i,                    "s"      ]
    [/$/,                      "s"      ]
  ]

  singular: [
    [/(quiz)zes$/i,                                                    "$1"     ]
    [/(matr)ices$/i,                                                   "$1ix"   ]
    [/(vert|ind)ices$/i,                                               "$1ex"   ]
    [/^(ox)en/i,                                                       "$1"     ]
    [/(alias|status)es$/i,                                             "$1"     ]
    [/(octop|vir)i$/i,                                                 "$1us"   ]
    [/(cris|ax|test)es$/i,                                             "$1is"   ]
    [/(shoe)s$/i,                                                      "$1"     ]
    [/(o)es$/i,                                                        "$1"     ]
    [/(bus)es$/i,                                                      "$1"     ]
    [/([m|l])ice$/i,                                                   "$1ouse" ]
    [/(x|ch|ss|sh)es$/i,                                               "$1"     ]
    [/(m)ovies$/i,                                                     "$1ovie" ]
    [/(s)eries$/i,                                                     "$1eries"]
    [/([^aeiouy]|qu)ies$/i,                                            "$1y"    ]
    [/([lr])ves$/i,                                                    "$1f"    ]
    [/(tive)s$/i,                                                      "$1"     ]
    [/(hive)s$/i,                                                      "$1"     ]
    [/([^f])ves$/i,                                                    "$1fe"   ]
    [/(^analy)ses$/i,                                                  "$1sis"  ]
    [/((a)naly|(b)a|(d)iagno|(p)arenthe|(p)rogno|(s)ynop|(t)he)ses$/i, "$1$2sis"]
    [/([ti])a$/i,                                                      "$1um"   ]
    [/(n)ews$/i,                                                       "$1ews"  ]
    [/s$/i,                                                            ""       ]
  ]

  irregular: [
    ['move',   'moves'   ]
    ['sex',    'sexes'   ]
    ['child',  'children']
    ['man',    'men'     ]
    ['person', 'people'  ]
  ]

  uncountable: [
    "sheep"
    "fish"
    "series"
    "species"
    "money"
    "rice"
    "information"
    "equipment"
  ]

_.mixin
  pluralize: (word) ->
    for i in [0...rules.uncountable.length]
      uncountable = rules.uncountable[i]
      if word.toLowerCase() == uncountable
        return uncountable

    for i in [0...rules.irregular.length]
      singular = rules.irregular[i][0]
      plural   = rules.irregular[i][1]
      if word.toLowerCase() == singular or word == plural
        return plural

    for i in [0...rules.plural.length]
      regex          = rules.plural[i][0]
      replaceString = rules.plural[i][1]
      if regex.test(word)
        return word.replace(regex, replaceString)

  singularize: (word) ->
    for i in [0...rules.uncountable.length]
      uncountable = rules.uncountable[i]
      if word.toLowerCase() == uncountable
        return uncountable

    for i in [0...rules.irregular.length]
      singular = rules.irregular[i][0]
      plural   = rules.irregular[i][1]
      if word.toLowerCase() == singular or word == plural
        return plural

    for i in [0...rules.singular.length]
      regex          = rules.singular[i][0]
      replaceString = rules.singular[i][1]
      if regex.test(word)
        return word.replace(regex, replaceString)

  underscore: (word) ->
    word.replace(/([a-zA-Z\d])([A-Z])/g,'$1_$2').toLowerCase()

  underscoreAndPluralize: (word) ->
    this.underscore(this.pluralize(word))

  camelize: (word, lowFirstLetter) ->
    parts = word.split('_')
    len = parts.length
    camelized = ""
    for i in [0...len]
      firstLetter =
        if lowFirstLetter && i == 0
          parts[i].charAt(0)
        else
          parts[i].charAt(0).toUpperCase()
      camelized += firstLetter + parts[i].substring(1)
    camelized

  underscoreKeys: (hash) ->
    newHash = {}
    for key, value of hash
      newHash[_.underscore(key)] = value
    newHash

  camelizeKeys: (hash) ->
    newHash = {}
    for key, value of hash
      newHash[_.camelize(key, true)] = value
    newHash

  capitalize: (word) ->
    word.charAt(0).toUpperCase() + word.substr(1)

  uncapitalize: (word) ->
    word.charAt(0).toLowerCase() + word.substr(1)