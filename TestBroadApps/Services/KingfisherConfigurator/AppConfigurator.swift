//
//  AppConfigurator.swift
//  TestBroadApps
//
//  Created by Abylaikhan Abilkayr on 11.10.2025.
//

import Kingfisher

final class AppConfigurator {
    static func configureKingfisher() {
        let downloader = ImageDownloader.default
        let cache = ImageCache.default

        // ⚙️ Ограничить одновременные соединения и увеличить таймаут
        let config = downloader.sessionConfiguration
        config.httpMaximumConnectionsPerHost = 2       // максимум 4 запроса на один хост
        config.timeoutIntervalForRequest = 60          // 60 секунд
        config.timeoutIntervalForResource = 180        // 3 минуты
        downloader.sessionConfiguration = config

        // ⏱️ Общий таймаут для Kingfisher
        downloader.downloadTimeout = 120

        // 💾 Кэш — ограничиваем память и диск
        cache.memoryStorage.config.totalCostLimit = 50 * 1024 * 1024 // 50MB в памяти
        cache.diskStorage.config.sizeLimit = 300 * 1024 * 1024       // 300MB на диске

        print("✅ Kingfisher настроен")
    }
}
