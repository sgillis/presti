module ListUtils where


(!) : List a -> Int -> Maybe a
xs ! n = case xs of
    [] -> Nothing
    (x :: xs) -> case n of
                      0 -> Just x
                      _ -> xs ! (n-1)

set : List a -> Int -> a -> List a
set xs n x = case xs of
    [] -> []
    (x' :: xs) -> case n of
                       0 -> x :: xs
                       _ -> x' :: (set xs (n-1) x)
