resource ResJap = open Prelude in {

flags coding = utf8 ;

param
  Number      = Sg | Pl ;
  Style       = Plain | Resp ;
  Animateness = Anim | Inanim ;
  Mood        = Ind | Con ;
  TTense      = TPres | TPast | TFut ;
  Polarity    = Pos | Neg ;
  ModSense    = Abil | Oblig | Wish ;
  Particle    = Wa | Ga ;
  Anteriority = Simul | Anter ;
  NumeralType = Tens | TensPlus | Other ;
  ComparSense = Less | More | NoCompar ;

oper

  NP          : Type = {s : Style => Str ; prepositive : Style => Str ; needPart : Bool ; 
                        changePolar : Bool ; Pron1Sg : Bool ; anim : Animateness} ;
  VP          : Type = {verb : Animateness => Style => TTense => Polarity => Str ; 
                        te : Animateness => Style => Str; a_stem : Animateness => Style => Str ; 
                        i_stem : Animateness => Style => Str ; tara : Animateness => Style => Str ; 
                        prep : Str ; obj : Style => Str ; prepositive : Style => Str ; 
                        compar : ComparSense} ;
                        
  Noun        : Type = {s : Number => Style => Str ; anim : Animateness ; 
                        counter : Str ; counterReplace : Bool} ;
  PropNoun    : Type = {s : Style => Str ; anim : Animateness} ;
  Adj         : Type = {pred : Style => TTense => Polarity => Str;
                        attr : Str; te : Str ; tara : Str ; adv : Str} ; 
  Adj2        : Type = {pred : Style => TTense => Polarity => Str;
                        attr : Str; te : Str ; tara : Str ; adv : Str ; prep : Str} ; 
  Adverb      : Type = {s : Style => Str ; prepositive : Bool ; compar : ComparSense} ;
  Pronoun     : Type = {s : Style => Str ; Pron1Sg : Bool ; anim : Animateness} ;
  Determiner  : Type = {quant : Style => Str ; postpositive : Str ; 
                        num : Str ; n : Number ; inclCard : Bool} ;
  Num         : Type = {s : Str ; postpositive : Str ; n : Number ; inclCard : Bool} ;
  Preposition : Type = {s : Str ; relPrep : Str} ;
  Verb        : Type = {s : Style => TTense => Polarity => Str ; te : Str ; 
                        a_stem : Str ; i_stem : Str ; tara : Str} ;
  Verb2       : Type = {s : Style => TTense => Polarity => Str ; te : Str ; 
                        a_stem : Str ; i_stem : Str ; tara : Str ;
                        pass : Style => TTense => Polarity => Str ; pass_te : Str ; 
                        pass_a_stem : Str ; pass_i_stem : Str ; pass_tara : Str ; 
                        prep : Str} ;
  Conjunction : Type = {s : Str ; pconj : Str ; disj : Bool} ;
                       
  mkNoun : Str -> Str -> Str -> Str -> Animateness -> Str -> Bool -> Noun = 
    \man1,man2,man3,man4,a,c,b -> {
      s = table {
        Sg => table {
          Plain => man1 ;
          Resp => man2
          } ;
        Pl => table {
          Plain => man3 ;
          Resp => man4
          }
        } ;
      anim = a ;
      counter = c ;
      counterReplace = b
    } ;
    
  regNoun : Str -> Animateness -> Str -> Bool -> Noun = \s,a,c,b -> mkNoun s s s s a c b ;
  
  styleNoun : Str -> Str -> Animateness -> Str -> Bool -> Noun = \kane,okane,a,c,b ->
    mkNoun kane okane kane okane a c b ;
  
  regAdj : Str -> Adj = \a -> case a of {
    chiisa + "い"       => i_mkAdj a ;
    ooki + ("な"|"の") => na_mkAdj a
    } ;

  i_mkAdj : Str -> Adj = \chiisai -> 
    let
      chiisa = init chiisai ;     
    in {
    pred = table {
      Resp => table {
        TPres => table {
          Pos => chiisai ++ "です" ;
          Neg => (chiisa + "くありません" | 
                  chiisa + "くないです")
          } ;
        TPast => table {
          Pos => chiisa + "かったです" ;
          Neg => (chiisa + "くありませんでした" | 
                  chiisa + "くなかったです")
          } ;
        TFut => table {
          Pos => chiisai ++ "です" ;
          Neg => (chiisa + "くありません" | 
                  chiisa + "くないです")
          }
        } ;
      Plain => table {
        TPres => table {
          Pos => chiisai ;
          Neg => chiisa + "くない"
          } ;
        TPast => table {
          Pos => chiisa + "かった" ;
          Neg => chiisa + "くなかった" 
          } ;
        TFut => table {
          Pos => chiisai ;
          Neg => chiisa + "くない"
          }
        }
      } ;
    attr = chiisai ;
    te   = chiisa + "くて" ;
    tara = chiisa + "かったら" ; 
    adv  = chiisa + "く"
    } ;  
  
  na_mkAdj : Str -> Adj = \ookina -> 
    let
      ooki = init ookina     
    in {
    pred = table {
      Resp => table {
        TPres => table {
          Pos => ooki ++ "です" ;
          Neg => ooki ++ "ではありません"
          } ;
        TPast => table {
          Pos => ooki ++ "でした" ;
          Neg => ooki ++ "ではありませんでした"
          } ;
        TFut => table {
          Pos => ooki ++ "です" ;
          Neg => ooki ++ "ではありません"
          }
        } ;
      Plain => table {
        TPres => table {
          Pos => ooki ++ "だ" ;
          Neg => ooki ++ "ではない"
          } ;
        TPast => table {
          Pos => ooki ++ "だった" ;
          Neg => ooki ++ "ではなかった"
          } ;
        TFut => table {
          Pos => ooki ++ "だ" ;
          Neg => ooki ++ "ではない"
          }
        }
      } ;
    attr = ookina ;
    te   = ooki + "で" ;
    tara = ooki + "だったら" ;
    adv  = ooki + "に"
    } ; 
    
  VerbalA : Str -> Str -> Adj = \kekkonshiteiru,kikonno -> 
    let
      kekkonshite = Predef.tk 2 kekkonshiteiru     
    in {
    pred = table {
      Resp => table {
        TPres => table {
          Pos => kekkonshite + "います" ;
          Neg => kekkonshite + "いません"
          } ;
        TPast => table {
          Pos => kekkonshite + "いました" ;
          Neg => kekkonshite + "いませんでした"
          } ;
        TFut => table {
          Pos => kekkonshite + "います" ;
          Neg => kekkonshite + "いません"
          }
        } ;
      Plain => table {
        TPres => table {
          Pos => kekkonshite + "いる" ;
          Neg => kekkonshite + "いない"
          } ;
        TPast => table {
          Pos => kekkonshite + "いた" ;
          Neg => kekkonshite + "いなかった"
          } ;
        TFut => table {
          Pos => kekkonshite + "いる" ;
          Neg => kekkonshite + "いない"
          }
        }
      } ;
    attr = kikonno ;
    te   = kekkonshite + "いて" ;
    tara = kekkonshite + "いたら" ;
    adv  = kekkonshite + "に"
    } ; 
  
  mkVerb : Str -> Str -> Str -> Str -> Verb = 
    \yoma,yomi,yomu,yonda ->  
      let yon = init yonda ;     
    in {
    s = table {
      Resp => table {
        TPres => table {
          Pos => yomi + "ます" ;
          Neg => yomi + "ません"
          } ;
        TPast => table {
          Pos => yomi + "ました" ;
          Neg => yomi + "ませんでした"
          } ;
        TFut => table {
          Pos => yomi + "ます" ;
          Neg => yomi + "ません"
          }
        } ;
      Plain => table {
        TPres => table {
          Pos => yomu ;
          Neg => yoma + "ない"
          } ;
        TPast => table {
          Pos => yonda ;
          Neg => yoma + "なかった"
          } ;
        TFut => table {
          Pos => yomu ;
          Neg => yoma + "ない"
          }
        }
      } ;
      te = case yonda of {
        yon + "だ" => yon + "で" ;
        yon + "た" => yon + "て"
        } ;
      a_stem = yoma ;
      i_stem = yomi ;
      tara = yomi + "たら"
    } ;
    
  mkVerb2 : Str -> Str -> Str -> Str -> Str -> Verb2 = 
    \yoma,yomi,yomu,yonda,p -> 
      let yon = init yonda ;     
    in {
    s = table {
      Resp => table {
        TPres => table {
          Pos => yomi + "ます" ;
          Neg => yomi + "ません"
          } ;
        TPast => table {
          Pos => yomi + "ました" ;
          Neg => yomi + "ませんでした"
          } ;
        TFut => table {
          Pos => yomi + "ます" ;
          Neg => yomi + "ません"
          }
        } ;
      Plain => table {
        TPres => table {
          Pos => yomu ;
          Neg => yoma + "ない"
          } ;
        TPast => table {
          Pos => yonda ;
          Neg => yoma + "なかった"
          } ;
        TFut => table {
          Pos => yomu ;
          Neg => yoma + "ない"
          }
        }
      } ;
    te = case yonda of {
      yon + "だ" => yon + "で" ;
      yon + "た" => yon + "て"
      } ;
    a_stem = yoma ;
    i_stem = yomi ;
    tara = yomi + "たら" ;
    prep = p ;
    pass = table {
      Resp => table {
        TPres => table {
          Pos => case yomu of {
            x + "する" => x + "されます" ;
            _        => yoma + "れます" 
            } ;
          Neg => case yomu of {
            x + "する" => x + "されません" ;
            _        => yoma + "れません"
            }
          } ;
        TPast => table {
          Pos => case yomu of {
            x + "する" => x + "されました" ;
            _        => yoma + "れました" 
            } ;
          Neg => case yomu of {
            x + "する" => x + "されませんでした" ;
            _        => yoma + "れませんでした"
            }
          } ;
        TFut => table {
          Pos => case yomu of {
            x + "する" => x + "されます" ;
            _        => yoma + "れます" 
            } ;
          Neg => case yomu of {
            x + "する" => x + "されません" ;
            _        => yoma + "れません"
            }
          }
        } ;
      Plain => table {
        TPres => table {
          Pos => case yomu of {
            x + "する" => x + "される" ;
            _        => yoma + "れる" 
            } ;
          Neg => case yomu of {
            x + "する" => x + "されない" ;
            _        => yoma + "れない"
            }
          } ;
        TPast => table {
          Pos => case yomu of {
            x + "する" => x + "された" ;
            _        => yoma + "れた" 
            } ;
          Neg => case yomu of {
            x + "する" => x + "されなかった" ;
            _        => yoma + "れなかった"
            }
          } ;
        TFut => table {
          Pos => case yomu of {
            x + "する" => x + "される" ;
            _        => yoma + "れる" 
            } ;
          Neg => case yomu of {
            x + "する" => x + "されない" ;
            _        => yoma + "れない"
            }
          }
        }
      } ;
    pass_te = case yomu of {
      x + "する" => x + "されて" ;
      _        => yoma + "れて" 
      } ;
    pass_a_stem = case yomu of {
      x + "する" => x + "され" ;
      _        => yoma + "れ" 
      } ;
    pass_i_stem = case yomu of {
      x + "する" => x + "され" ;
      _        => yoma + "れ" 
      } ;
    pass_tara = case yomu of {
      x + "する" => x + "されたら" ;
      _        => yoma + "れたら" 
      }
    } ;
  
  mkCopula : Verb = {
    s = table {
      Resp => table {
        TPres => table {
          Pos => "です" ;
          Neg => "ではありません" 
          } ;
        TPast => table {
          Pos => "でした" ;
          Neg => "ではありませんでした"
          } ;
        TFut => table {
          Pos => "です" ;
          Neg => "ではありません" 
          }
        } ;
      Plain => table {
        TPres => table {
          Pos => "だ" ;
          Neg => "ではない"
          } ;
        TPast => table {
          Pos => "だった" ;
          Neg => "ではなかった"
          } ;
        TFut => table {
          Pos => "だ" ;
          Neg => "ではない"
          }
        }
      } ;
    te = "だって" ;
    a_stem = "で" ;
    i_stem = "で" ;
    tara = "だったら"
    } ;
  
  mkExistV : VP = {
    verb = table {
      Anim => \\st,t,p => (mkVerb "い" "い" "いる" "いた").s ! st ! t ! p ;
      Inanim => \\st,t,p => (mkVerb "" "あり" "ある" "あった").s ! st ! t ! p 
      } ;
    te = table {
      Anim => \\st => "いて" ;
      Inanim => \\st => "あって"
      } ;
    a_stem = table {
      Anim => \\st => "い" ;
      Inanim => \\st => ""
      } ;
    i_stem = table {
      Anim => \\st => "い" ;
      Inanim => \\st => "あり"
      } ;
    tara = table {
      Anim => \\st => "いたら" ;
      Inanim => \\st => "あったら"
      } ;
    prep = [] ;
    prepositive, obj = \\st => [] ;
    compar = NoCompar
    } ;
    
  mkNum : Str -> Number -> Bool -> Num = \s,n,b -> {
    s = s ;
    postpositive = [] ;
    n = n ;
    inclCard = b
    } ;
  
  regPron : Str -> Bool -> Animateness -> Pronoun = \kare,b,a -> {
    s = \\st => kare ;
    Pron1Sg = b ;
    anim = a
    } ;    
  
  mkDet : Str -> Number -> Determiner = \q,n -> {
    quant = \\st => q ;
    postpositive = [] ;
    num = [] ;
    n = n ;
    inclCard = False
    } ;
                       
  stylePron : Str -> Str -> Bool -> Animateness -> Pronoun = \boku,watashi,b,a -> {
    s = table {
      Plain => boku ;
      Resp => watashi
      } ;
    Pron1Sg = b ;
    anim = a
    } ;    
    
  regPN : Str -> PropNoun = \paris -> {
    s = table {
      Plain => paris ;
      Resp => paris
      } ;
    anim = Inanim
    } ;
  
  personPN : Str -> Str -> PropNoun = \jon,jonsan -> {
    s = table {
      Plain => jon ;
      Resp => jonsan
      } ;
    anim = Anim
    } ;
  
  mkAdv : Str -> Adverb = \adv -> {
    s = \\st => adv ; 
    prepositive = False ;
    compar = NoCompar 
    } ;
  
  mkNP : Str -> Bool -> Bool -> Animateness -> NP = \np,b1,b2,a -> {
    s = \\st => np ; 
    prepositive = \\st => [] ;
    needPart = b1 ; 
    changePolar = b2 ; 
    Pron1Sg = False ; 
    anim = a
    } ;
  
  mkConj : Str -> Str -> Bool -> Conjunction = \c,p,b -> {
    s = c ;
    pconj = p ;
    disj = b
    } ;
    
  mkPrep : Str -> Str -> Preposition = \p,r -> {
    s = p ;
    relPrep = r ;
    } ;

}
