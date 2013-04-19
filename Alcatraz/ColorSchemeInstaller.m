// ColorSchemeInstaller.m
//
// Copyright (c) 2013 mneorr.com
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.


#import "ColorSchemeInstaller.h"
#import "ColorScheme.h"

static NSString *const LOCAL_COLOR_SCHEMES_RELATIVE_PATH = @"Library/Developer/Xcode/UserData/FontAndColorThemes";
@implementation ColorSchemeInstaller

#pragma mark - Public

- (void)installPackage:(ColorScheme *)package progress:(void (^)(CGFloat))progress
            completion:(void (^)(void))completion failure:(void (^)(NSError *))failure {
    
    Downloader *downloader = [Downloader new];
    [downloader downloadFileFromURL:package.url completion:^(NSData *responseData) {

            [self installColorScheme:package withContents:responseData];
            completion();
            [downloader release];
    }
        failure:^(NSError *error) {
            failure(error);
            [downloader release];
    }];
}

- (void)removePackage:(ColorScheme *)package
           completion:(void (^)(void))completion failure:(void (^)(NSError *))failure {

    NSError *error;
    [[NSFileManager sharedManager] removeItemAtPath:[self filePathForColorScheme:package] error:&error];
    
    error ? failure(error) : completion();
}

- (BOOL)isPackageInstalled:(ColorScheme *)package {
    
    return [[NSFileManager sharedManager] fileExistsAtPath:[self filePathForColorScheme:package] isDirectory:NO];
}

#pragma mark - Private

- (void)installColorScheme:(ColorScheme *)colorScheme withContents:(NSData *)contents {
    if ([[NSFileManager sharedManager] createFileAtPath:[self filePathForColorScheme:colorScheme] contents:contents attributes:nil])
        NSLog(@"Color scheme installed!");
    else
        NSLog(@"There was a problem with installing the color scheme :(");

}

- (NSString *)filePathForColorScheme:(ColorScheme *)colorScheme {
    return [NSString stringWithFormat:@"%@.dvtcolortheme",
            [NSString stringWithFormat:@"%@/%@/%@", NSHomeDirectory(), LOCAL_COLOR_SCHEMES_RELATIVE_PATH, colorScheme.name]];
}

@end
