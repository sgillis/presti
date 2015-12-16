module ListUtils where

import Random
import Random.Array exposing (shuffle)
import Array
import List


(!) : List a -> Int -> Maybe a
(!) xs n = case xs of
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

(!!) : List a -> Int -> Maybe a
(!!) xs n =
  case xs of
    (x :: xs) -> case n of
                      0 -> Just x
                      _ -> xs !! (n-1)
    [] -> Nothing

randomize : Int -> List a -> List a
randomize initSeed xs =
  let gen = shuffle (Array.fromList xs)
      seed = Random.initialSeed initSeed
      (array, seed') = Random.generate gen seed
  in Array.toList array

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
