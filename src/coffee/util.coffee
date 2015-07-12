"use strict"

module.exports =
  querySelector: (selector) -> document.querySelector selector
  addListener: (el, type, handler, useCapture = false) ->
    el.addEventListener type, handler, useCapture
  rmListener: (el, type, handler, useCapture = false) ->
    el.removeEventListener type, handler, useCapture
  remove: (el) -> el.parentNode.removeChild el
  toggleClass: (el, className) ->
    if el.classList
      el.classList.toggle className
    else
      classes = el.className.split ' '
      existingIndex = classes.indexOf className

      if existingIndex >= 0
        classes.splice existingIndex, 1
      else
        classes.push className

      el.className = classes.join ' '
