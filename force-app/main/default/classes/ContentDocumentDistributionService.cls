/**
 * Resolves the latest {@link ContentVersion} for a {@link ContentDocument} and creates a {@link ContentDistribution}
 * so callers obtain a public viewer URL ({@code DistributionPublicUrl}) for use outside Salesforce (e.g. LLM prompts).
 */
public with sharing class ContentDocumentDistributionService {
    public class ContentDocumentDistributionException extends Exception {
    }

    /**
     * @param contentDocumentId Salesforce ContentDocument Id (key prefix {@code 069}).
     * @return {@code DistributionPublicUrl} from the inserted Content Distribution row (re-queried after insert).
     */
    public static String getDistributionPublicUrl(Id contentDocumentId) {
        if (contentDocumentId == null) {
            throw new ContentDocumentDistributionException('contentDocumentId is required.');
        }
        String sid = String.valueOf(contentDocumentId);
        if (sid.length() < 3 || sid.substring(0, 3) != '069') {
            throw new ContentDocumentDistributionException(
                'contentDocumentId must be a ContentDocument Id (069 prefix). Got: ' + sid
            );
        }

        List<ContentVersion> latest = [
            SELECT Id
            FROM ContentVersion
            WHERE ContentDocumentId = :contentDocumentId AND IsLatest = TRUE
            LIMIT 1
        ];
        if (latest.isEmpty()) {
            throw new ContentDocumentDistributionException(
                'No latest ContentVersion for ContentDocument ' + sid + ' (missing or not accessible).'
            );
        }
        Id contentVersionId = latest[0].Id;

        ContentDistribution dist = new ContentDistribution();
        dist.Name = 'ContentDocumentDistributionService ' + sid + ' ' + String.valueOf(System.now().getTime());
        dist.ContentVersionId = contentVersionId;
        dist.PreferencesAllowOriginalDownload = true;
        dist.PreferencesAllowViewInBrowser = true;
        dist.PreferencesPasswordRequired = false;
        insert dist;

        List<ContentDistribution> rows = [
            SELECT DistributionPublicUrl
            FROM ContentDistribution
            WHERE Id = :dist.Id
            LIMIT 1
        ];
        if (rows.isEmpty()) {
            throw new ContentDocumentDistributionException('ContentDistribution row missing after insert.');
        }
        String publicUrl = rows[0].DistributionPublicUrl;
        if (String.isBlank(publicUrl)) {
            throw new ContentDocumentDistributionException(
                'DistributionPublicUrl was not populated. Ensure Content Deliveries are enabled and the user can create distributions for this file.'
            );
        }
        return publicUrl;
    }
}