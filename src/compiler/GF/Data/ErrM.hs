----------------------------------------------------------------------
-- |
-- Module      : ErrM
-- Maintainer  : AR
-- Stability   : (stable)
-- Portability : (portable)
--
-- > CVS $Date: 2005/04/21 16:22:00 $ 
-- > CVS $Author: bringert $
-- > CVS $Revision: 1.5 $
--
-- hack for BNFC generated files. AR 21/9/2003
-----------------------------------------------------------------------------

module GF.Data.ErrM where

import Control.Monad (MonadPlus(..),ap)
import Control.Applicative

-- | Like 'Maybe' type with error msgs
data Err a = Ok a | Bad String
  deriving (Read, Show, Eq)

-- | Analogue of 'maybe'
err :: (String -> b) -> (a -> b) -> Err a -> b 
err d f e = case e of
  Ok a -> f a
  Bad s -> d s

-- | Analogue of 'fromMaybe'
fromErr :: a -> Err a -> a
fromErr a = err (const a) id

instance Monad Err where
  return      = Ok
  fail        = Bad
  Ok a  >>= f = f a
  Bad s >>= f = Bad s

-- | added 2\/10\/2003 by PEB
instance Functor Err where
  fmap f (Ok a) = Ok (f a)
  fmap f (Bad s) = Bad s

instance Applicative Err where
  pure = return
  (<*>) = ap

-- | added by KJ
instance MonadPlus Err where
    mzero = Bad "error (no reason given)"
    mplus (Ok a)  _ = Ok a
    mplus (Bad s) b = b

instance Alternative Err where
    empty = mzero
    (<|>) = mplus
