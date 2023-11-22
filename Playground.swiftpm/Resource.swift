import Foundation

enum AnimatedImageResource {
    case apng(String)
    case gif(String)
    case webp(String)
}

struct AnimatedImageResourceItem: Identifiable {
    let id: UUID = UUID()
    let rawValue: AnimatedImageResource
}

extension AnimatedImageResource {
    static var examples: [AnimatedImageResource] {
        // https://emoji.gg/pack/6241-blobs#
        [
            .apng("elephant"),
            .webp("animated-webp-supported"),
            .gif("1342-splash"),
            .gif("1904-blob-dancing"),
            .gif("2671-blobsupersaiyan"),
            .gif("2697-cookieblob"),
            .gif("4817-blobbottleflip"),
            .gif("5883-blob"),
            .gif("5907-dracthyrdance"),
            .gif("6292-blob-cat-whacky-fast"),
            .gif("7164-blobtrash"),
            .gif("7514-bouncingrainbowblob"),
            .gif("7766-blobpokemon"),
            .gif("7896-blob-jam"),
            .gif("7953-blobknight"),
            .gif("8551-blob-swallow"),
            .gif("8843-blobdrum"),
            .gif("8899-blob-cat-pop"),
            .gif("8967-blob-cat-dance"),
            .gif("8996-blob"),
            .gif("9507-blobsnow"),
        ]
    }
}
