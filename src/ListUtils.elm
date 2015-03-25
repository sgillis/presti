module ListUtils where

import Random
import List


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

(!!) : List a -> Int -> a
(!!) xs n = case xs of
    (x :: xs) -> case n of
                      0 -> x
                      _ -> xs !! (n-1)

randomize : Int -> List a -> List a
randomize x xs = randomize' (Random.initialSeed x) xs

randomize' : Random.Seed -> List a -> List a
randomize' seed xs = case xs of
    [] -> []
    xs -> let (chosen, xs', newSeed) = fisherYatesStep seed xs
          in chosen :: randomize' newSeed xs'

fisherYatesStep : Random.Seed -> List a -> (a, List a, Random.Seed)
fisherYatesStep seed xs =
    let generator = Random.int 0 (List.length xs - 1)
        (randomN, newSeed) = Random.generate generator seed
        chosen = xs !! randomN
        xs' = drop randomN xs
    in (chosen, xs', newSeed)

drop : Int -> List a -> List a
drop x xs = case xs of
    [] -> []
    (x' :: xs') -> case x of
                        0 -> xs'
                        _ -> x' :: (drop (x-1) xs')

zip : List a -> List b -> List (a, b)
zip xs ys =
    case xs of
         []       -> []
         (x::xs') -> case ys of
                          []       -> []
                          (y::ys') -> (x,y) :: (zip xs' ys')
