// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review_prompt_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(reviewPromptService)
final reviewPromptServiceProvider = ReviewPromptServiceProvider._();

final class ReviewPromptServiceProvider
    extends
        $FunctionalProvider<
          ReviewPromptService,
          ReviewPromptService,
          ReviewPromptService
        >
    with $Provider<ReviewPromptService> {
  ReviewPromptServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'reviewPromptServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$reviewPromptServiceHash();

  @$internal
  @override
  $ProviderElement<ReviewPromptService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ReviewPromptService create(Ref ref) {
    return reviewPromptService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ReviewPromptService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ReviewPromptService>(value),
    );
  }
}

String _$reviewPromptServiceHash() =>
    r'fd55899600bc95747fccc08ae1219ee90c5b4f17';
