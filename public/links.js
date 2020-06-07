if (('standalone' in navigator) && navigator.standalone) {
    document.addEventListener('click', function(e) {
      var curnode = e.target
      while (!(/^(a|html)$/i).test(curnode.nodeName)) {
        curnode = curnode.parentNode
      }
      if ('href' in curnode
        && (chref = curnode.href).replace(document.location.href, '').indexOf('#')
        && (!(/^[a-z\+\.\-]+:/i).test(chref)
        || chref.indexOf(document.location.protocol + '//' + document.location.host) === 0)
      ) {
        e.preventDefault()
        document.location.href = curnode.href
      }
    }, false)

    document.addEventListener('submit', function(e) {
        var curnode = e.target
        while (!(/^(a|html)$/i).test(curnode.nodeName)) {
          curnode = curnode.parentNode
        }
        if ('href' in curnode
          && (chref = curnode.href).replace(document.location.href, '').indexOf('#')
          && (!(/^[a-z\+\.\-]+:/i).test(chref)
          || chref.indexOf(document.location.protocol + '//' + document.location.host) === 0)
        ) {
          e.preventDefault()
          document.location.href = curnode.href
        }
      }, false)
  }
  