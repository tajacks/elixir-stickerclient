defmodule StickerClient do
  @moduledoc """
  `StickerClient` is a library for interfacing with the Signal Stickers API. 



  ## Downloading 

  Download operations work primarily on two elements, Packs and Stickers. These are 
  represented as `StickerClient.Pack` and `StickerClient.Sticker` respectively. A Pack
  struct contains information about the sticker pack. It is a translated view of Signals 
  manifest [protobuf definition](https://signal.art/addstickers/Stickers.proto). The Pack
  may or may not contain sticker definitions with content, depending on how the API is called. 

  Most likely, manifests will be downloaded alongside their sticker content in full. The 
  Pack ID and Pack Key can be provided individually, or parsed from a valid URL. 

      iex(1)> StickerClient.Downloader.download_pack("https://signal.art/addstickers/#pack_id=45bdc863f62e6a2548052e0a0c4cb153&pack_key=9dc85e4d5d65d0b272274e5bd4f047fcda3551e77f89053c06078ace81fa6a41")
      {:ok,
       %StickerClient.Pack{
         title: "oh my frog by ilaso",
         author: "https://t.me/addstickers/ohmyfrog_ilaso",
         cover: %StickerClient.Protos.Pack.Sticker{
           id: 0,
           emoji: nil,
           __unknown_fields__: []
         },
         stickers: [
           %StickerClient.Sticker{
             id: 0,
             emoji: "👍",
             data: <<82, 73, 70, 70, 242, 85, 0, 0, 87, 69, 66, 80, 86, 80, 56, 88,
               10, 0, 0, 0, 16, 0, 0, 0, 255, 1, 0, 255, 1, 0, 65, 76, 80, 72, 151,
               27, 0, 0, 1, 240, ...>>
           },
           %StickerClient.Sticker{
             id: 1,
             emoji: "🐸",
             data: <<82, 73, 70, 70, 170, 100, 0, 0, 87, 69, 66, 80, 86, 80, 56, 88,
               10, 0, 0, 0, 16, 0, 0, 0, 255, 1, 0, 255, 1, 0, 65, 76, 80, 72, 32, 31,
               0, 0, 1, ...>>
           },
           %StickerClient.Sticker{
             id: 2,
             emoji: "🐸",
             data: <<82, 73, 70, 70, 52, 60, 0, 0, 87, 69, 66, 80, 86, 80, 56, 88, 10,
               0, 0, 0, 16, 0, 0, 0, 255, 1, 0, 255, 1, 0, 65, 76, 80, 72, 77, 21, 0,
               0, ...>>
           },
           %StickerClient.Sticker{
             id: 3,
             emoji: "🐸",
             data: <<82, 73, 70, 70, 80, 82, 0, 0, 87, 69, 66, 80, 86, 80, 56, 88, 10,
               0, 0, 0, 16, 0, 0, 0, 255, 1, 0, 255, 1, 0, 65, 76, 80, 72, 79, 30, 0,
               ...>>
           },
           %StickerClient.Sticker{
             id: 4,
             emoji: "🐸",
             data: <<82, 73, 70, 70, 18, 76, 0, 0, 87, 69, 66, 80, 86, 80, 56, 88, 10,
               0, 0, 0, 16, 0, 0, 0, 255, 1, 0, 255, 1, 0, 65, 76, 80, 72, 117, 21,
               ...>>
           } 
           ... CONTINUED
           
  It is possible, using the downloader, to only retrieve a manifest: 


      iex> StickerClient.Downloader.download_manifest("45bdc863f62e6a2548052e0a0c4cb153", "9dc85e4d5d65d0b272274e5bd4f047fcda3551e77f89053c06078ace81fa6a41")
      {:ok,
       %StickerClient.Pack{
         title: "oh my frog by ilaso",
         author: "https://t.me/addstickers/ohmyfrog_ilaso",
         cover: %StickerClient.Protos.Pack.Sticker{
           id: 0,
           emoji: nil,
           __unknown_fields__: []
         },
         stickers: [
           %StickerClient.Sticker{id: 0, emoji: "👍", data: nil},
           %StickerClient.Sticker{id: 1, emoji: "🐸", data: nil},
           %StickerClient.Sticker{id: 2, emoji: "🐸", data: nil},
           %StickerClient.Sticker{id: 3, emoji: "🐸", data: nil},
           %StickerClient.Sticker{id: 4, emoji: "🐸", data: nil},
           %StickerClient.Sticker{id: 5, emoji: "🐸", data: nil},
           %StickerClient.Sticker{id: 6, emoji: "🐸", data: nil},
           %StickerClient.Sticker{id: 7, emoji: "🐸", data: nil},
           %StickerClient.Sticker{id: 8, emoji: "🐸", data: nil},
           %StickerClient.Sticker{id: 9, emoji: "🐸", data: nil},
           %StickerClient.Sticker{id: 10, emoji: "🐸", data: nil},
           %StickerClient.Sticker{id: 11, emoji: "🐸", data: nil},
           %StickerClient.Sticker{id: 12, emoji: "🐸", data: nil},
           %StickerClient.Sticker{id: 13, emoji: "🐸", data: nil},
           %StickerClient.Sticker{id: 14, emoji: "🐸", data: nil},
           %StickerClient.Sticker{id: 15, emoji: "🐸", data: nil},
           %StickerClient.Sticker{id: 16, emoji: "🐸", data: nil},
           %StickerClient.Sticker{id: 17, emoji: "🐸", data: nil},
           %StickerClient.Sticker{id: 18, emoji: "🐸", data: nil},
           %StickerClient.Sticker{id: 19, emoji: "🐸", data: nil},
           %StickerClient.Sticker{id: 20, emoji: "🐸", data: nil},
           %StickerClient.Sticker{id: 21, emoji: "🐸", data: nil},
           %StickerClient.Sticker{id: 22, emoji: "🐸", data: nil},
           %StickerClient.Sticker{id: 23, emoji: "🐸", data: nil},
           %StickerClient.Sticker{id: 24, emoji: "🐸", data: nil},
           %StickerClient.Sticker{id: 25, emoji: "🐸", data: nil},
           %StickerClient.Sticker{id: 26, emoji: "🐸", data: nil},
           %StickerClient.Sticker{id: 27, emoji: "🐸", data: nil},
           %StickerClient.Sticker{id: 28, emoji: "🐸", data: nil},
           %StickerClient.Sticker{id: 29, emoji: "🐸", data: nil},
           %StickerClient.Sticker{id: 30, emoji: "🐸", data: nil},
           %StickerClient.Sticker{id: 31, emoji: "🐸", data: nil},
           %StickerClient.Sticker{id: 32, emoji: "🐸", data: nil},
           %StickerClient.Sticker{id: 33, emoji: "🐸", data: nil},
           %StickerClient.Sticker{id: 34, emoji: "🐸", data: nil},
           %StickerClient.Sticker{id: 35, emoji: "🐸", data: nil},
           %StickerClient.Sticker{id: 36, emoji: "🐸", data: nil},
           %StickerClient.Sticker{id: 37, emoji: "🐸", data: nil},
           %StickerClient.Sticker{id: 38, emoji: "🐸", data: nil},
           %StickerClient.Sticker{id: 39, emoji: "🐸", data: nil}
         ]
       }}

  In the above example, the sticker data is `nil`. We have retrieved only the representation of the stickers, not the sticker data. 

  Sticker data can be downloaded on a per-sticker-basis by providing either the ID or the `StickerClient.Sticker` struct to 
  `StickerClient.Downloader.download_sticker/3`. If an ID is provided only, the emoji will not be populated, as this comes from the manifest:

      iex> StickerClient.Downloader.download_sticker(10, "45bdc863f62e6a2548052e0a0c4cb153", "9dc85e4d5d65d0b272274e5bd4f047fcda3551e77f89053c06078ace81fa6a41")
      {:ok,
       %StickerClient.Sticker{
         id: 10,
         emoji: nil,
         data: <<82, 73, 70, 70, 0, 87, 0, 0, 87, 69, 66, 80, 86, 80, 56, 88, 10, 0,
           0, 0, 16, 0, 0, 0, 255, 1, 0, 255, 1, 0, 65, 76, 80, 72, 24, 33, 0, 0, 1,
           240, 135, 109, 219, 43, 39, ...>>
       }}

  Enumerables of integers IDs or `StickerClient.Sticker`'s can also be provided: 

      iex> StickerClient.Downloader.download_stickers(1..3, "45bdc863f62e6a2548052e0a0c4cb153", "9dc85e4d5d65d0b272274e5bd4f047fcda3551e77f89053c06078ace81fa6a41")
      [
        %StickerClient.Sticker{
          id: 1,
          emoji: nil,
          data: <<82, 73, 70, 70, 170, 100, 0, 0, 87, 69, 66, 80, 86, 80, 56, 88, 10,
            0, 0, 0, 16, 0, 0, 0, 255, 1, 0, 255, 1, 0, 65, 76, 80, 72, 32, 31, 0, 0,
            1, 240, 199, 255, 255, 35, 39, 217, ...>>
        },
        %StickerClient.Sticker{
          id: 2,
          emoji: nil,
          data: <<82, 73, 70, 70, 52, 60, 0, 0, 87, 69, 66, 80, 86, 80, 56, 88, 10, 0,
            0, 0, 16, 0, 0, 0, 255, 1, 0, 255, 1, 0, 65, 76, 80, 72, 77, 21, 0, 0, 1,
            240, 70, 109, 219, 114, 167, ...>>
        },
        %StickerClient.Sticker{
          id: 3,
          emoji: nil,
          data: <<82, 73, 70, 70, 80, 82, 0, 0, 87, 69, 66, 80, 86, 80, 56, 88, 10, 0,
            0, 0, 16, 0, 0, 0, 255, 1, 0, 255, 1, 0, 65, 76, 80, 72, 79, 30, 0, 0, 1,
            240, 135, 109, 219, 51, ...>>
        }
      ]

  As previously mentioned, `StickerClient.Sticker` structs are also valid input, and thus manifest definitions can be 
  used to retrieve some or all of the stickers they define. If retrieved in this manner, the emoji field will be 
  populated alongside ID and the sticker data:

      iex> {:ok, manifest} = StickerClient.Downloader.download_manifest("45bdc863f62e6a2548052e0a0c4cb153", "9dc85e4d5d65d0b272274e5bd4f047fcda3551e77f89053c06078ace81fa6a41")
      iex> manifest.stickers |> Enum.take(3) |> StickerClient.Downloader.download_stickers("45bdc863f62e6a2548052e0a0c4cb153", "9dc85e4d5d65d0b272274e5bd4f047fcda3551e77f89053c06078ace81fa6a41")
      [
        %StickerClient.Sticker{
          id: 0,
          emoji: "👍",
          data: <<82, 73, 70, 70, 242, 85, 0, 0, 87, 69, 66, 80, 86, 80, 56, 88, 10,
            0, 0, 0, 16, 0, 0, 0, 255, 1, 0, 255, 1, 0, 65, 76, 80, 72, 151, 27, 0, 0,
            1, 240, 135, 109, 187, 42, 167, 253, ...>>
        },
        %StickerClient.Sticker{
          id: 1,
          emoji: "🐸",
          data: <<82, 73, 70, 70, 170, 100, 0, 0, 87, 69, 66, 80, 86, 80, 56, 88, 10,
            0, 0, 0, 16, 0, 0, 0, 255, 1, 0, 255, 1, 0, 65, 76, 80, 72, 32, 31, 0, 0,
            1, 240, 199, 255, 255, 35, 39, ...>>
        },
        %StickerClient.Sticker{
          id: 2,
          emoji: "🐸",
          data: <<82, 73, 70, 70, 52, 60, 0, 0, 87, 69, 66, 80, 86, 80, 56, 88, 10, 0,
            0, 0, 16, 0, 0, 0, 255, 1, 0, 255, 1, 0, 65, 76, 80, 72, 77, 21, 0, 0, 1,
            240, 70, 109, 219, 114, ...>>
        }
      ]
  """
end
