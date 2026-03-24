// Disputes feature barrel file

// Domain
export 'domain/entities/dispute.dart';
export 'domain/entities/dispute_type.dart';
export 'domain/entities/dispute_status.dart';
export 'domain/entities/dispute_evidence.dart';
export 'domain/repositories/dispute_repository.dart';
export 'domain/usecases/create_dispute_usecase.dart';
export 'domain/usecases/get_dispute_details_usecase.dart';
export 'domain/usecases/get_my_disputes_usecase.dart';
export 'domain/usecases/submit_evidence_usecase.dart';
export 'domain/usecases/respond_to_dispute_usecase.dart';
export 'domain/usecases/escalate_dispute_usecase.dart';
export 'domain/usecases/cancel_dispute_usecase.dart';
export 'domain/usecases/accept_resolution_usecase.dart';

// Data
export 'data/models/dispute_model.dart';
export 'data/models/dispute_evidence_model.dart';
export 'data/models/dispute_message_model.dart';
export 'data/models/dispute_resolution_model.dart';
export 'data/datasources/dispute_remote_datasource.dart';
export 'data/datasources/dispute_local_datasource.dart';
export 'data/repositories/dispute_repository_impl.dart';

// Presentation
export 'presentation/bloc/dispute_bloc.dart';
export 'presentation/bloc/dispute_event.dart';
export 'presentation/bloc/dispute_state.dart';
export 'presentation/pages/my_disputes_page.dart';
export 'presentation/pages/dispute_details_page.dart';
export 'presentation/pages/create_dispute_page.dart';
export 'presentation/pages/dispute_chat_page.dart';
export 'presentation/pages/submit_evidence_page.dart';
export 'presentation/widgets/dispute_card.dart';
export 'presentation/widgets/dispute_status_timeline.dart';
export 'presentation/widgets/evidence_gallery.dart';
export 'presentation/widgets/evidence_upload_widget.dart';
export 'presentation/widgets/dispute_type_selector.dart';
export 'presentation/widgets/resolution_card.dart';
export 'presentation/widgets/dispute_message_bubble.dart';
