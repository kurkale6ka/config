instance Functor (Either a) where    -- Either a has nothing to do with currying, it is simple substitution
    fmap f (Right x) = Right (f x)   -- Right is usually used for the result
    fmap f (Left x) = Left x         -- Left is usually used for the error

:t fmap
Functor f => (x -> y) -> f x -> f y

So we would have ... (x -> y) -> Either a x -> Either a y
                                 --------      --------
To match Either type1 type2,         \            /
  we use Right x                     Left unchanged
     and Left x
