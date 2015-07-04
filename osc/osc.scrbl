#lang scribble/manual


@title{@bold{OSC}: Open Sound Control Byte String Conversion}

@author[(author+email "John Clements" "clements@racket-lang.org")]

@(require (for-label racket
                     "main.rkt"))

@defmodule[osc]{This collection provides the means to translate
 to and from byte strings representing OSC (Open Sound Control) bundles and 
 messages.

 In OSC, the bytes you actually put on the wire represent an "element":

 @racketgrammar[#:literals (osc-bundle osc-message list)
                osc-element
                (osc-bundle timestamp (list osc-element ...))
                (osc-message address (list osc-value ...))]

  A bundle is just a list of elements with a timestamp attached. What
 if a nested element contains a different timestamp? Good question.

 
 @defproc[(osc-element->bytes [element osc-element?]) bytes?]{
 Given an osc element, produces the corresponding byte string.
 
 Here's an example of using it:
 
 @racketblock[
 (osc-element->bytes 
 (osc-message #"/abc/def"
              (list
               3 6 2.278 
               #"froggy"
               `(blob #"derple"))))]
 
 produces:
 
 @racketblock[#"/abc/def\0\0\0\0,iifsb\0\0\0\0\0\3\0\0\0\6@\21\312\301froggy\0\0\0\0\0\6derple\0\0"]
 }
 
 @defproc[(bytes->osc-element (bytes bytes?)) osc-element?]{Given a byte
 string, produces the corresponding byte string.
 
 Here's an example of using it:
 
 @racketblock[(bytes->osc-element
               #"/abc/def\0\0\0\0,iifsb\0\0\0\0\0\3\0\0\0\6@\21\312\301froggy\0\0\0\0\0\6derple\0\0")]
 
 produces
 
 @racketblock[
 (osc-message
  #"/abc/def"
  (3 6 2.2780001163482666 #"froggy" (blob #"derple")))]
 }
 
 Composing these two should be the identity for legal OSC elements up to number inexactness, as seen here
 (or legal byte strings, if composed the other way).
 
 @defproc[(osc-element? (value any/c)) boolean?]{
 Returns @racket[true] when called with an OSC Element
         
 
 An OSC Element is either a bundle or a message.
 
 }
 
 @defstruct*[osc-bundle ((timestamp osc-date?) (elements (listof osc-element?))) #:prefab]{
 Represents a bundle of elements with a common timestamp.}
                       
 An OSC Message consists of an address and arguments:
 
 @defstruct*[osc-message ((address byte-string?) (args (listof osc-value?))) #:prefab]{
 Essentially represents a remote procedure call. The @racket[address] is like
  the name of the message--- @racket[#"/start_note"], or
 @racket[#"/notify"], and the list of args are like the arguments.}
                       
 An OSC value is one of a number of different kinds of s-expressions. Let me know if you can see a 
 better way to document this:
 
 @defproc[(osc-value? (value any/c)) boolean?]{
 Returns true for OSC values. Here's the definition:
                                               

@#reader scribble/comment-reader
(racketblock
(define (osc-value? v)
  (or (int32? v) ; just the number
      (int64? v) ; (list 'h number)
      (osc-date? v) ; either 'now or a list of two uint32s
      (float32? v) ; just the [inexact] number
      (osc-double? v) ; (list 'd <inexact>)
      (no-nul-bytes? v) ; a byte-string
      (osc-symbol? v) ; (list 'S <byte-string>)
      (blob? v) ; (list 'blob <byte-string>)
      (osc-char? v) ; (list 'c byte)
      (osc-color? v) ; (list 'r <4bytes>)
      (osc-midi? v) ; (list 'm <4bytes>)
      (boolean? v) ; boolean?
      (null? v) 
      (osc-inf? v) ; 'infinitum
      (osc-array? v) ; (list 'arr (listof osc-value?))
      ))
)
}
 
 @defproc[(osc-date? (value any/c)) boolean?]{Returns true for an OSC date, 
 which can be either the special symbol @racket['now] or a list of two 
 natural numbers representable as unsigned 32-bit integers. The first one
 represents the number of seconds since January 1, 1900, and the second
 one forms the fractional part of a fixed-point representation. That is, the
 number @racket[#x80000000] represents half a second.
 
 Note that I have not tried very hard to independently confirm the number of
 seconds between January 1, 1900, and the UNIX epoch, so my computation may
 very well disagree with that of other OSC implementations; let me know if
 I'm mistaken.
 }
}
@section{Reporting Bugs}

For Heaven's sake, report lots of bugs!