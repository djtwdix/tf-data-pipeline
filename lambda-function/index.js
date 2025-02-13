const {
  S3Client,
  GetObjectCommand,
  PutObjectCommand,
} = require("@aws-sdk/client-s3");

const s3 = new S3Client({ region: "us-east-1" });

exports.handler = async (event) => {
  console.log("Event:", JSON.stringify(event, null, 2));
  const bucket = event.Records[0].s3.bucket.name;
  const key = event.Records[0].s3.object.key;

  const getObjectCommand = new GetObjectCommand({ Bucket: bucket, Key: key });
  const { Body } = await s3.send(getObjectCommand);

  // Convert stream to string
  const fileContent = await Body.transformToString();

  const contentObj = JSON.parse(fileContent);

  contentObj.processed = true;

  console.log("Processed Content: ", contentObj);

  const putObjectCommand = new PutObjectCommand({
    Bucket: bucket,
    Key: key,
    Body: JSON.stringify(contentObj),
    ContentType: "application/json",
  });

  await s3.send(putObjectCommand);

  return {
    statusCode: 200,
    body: JSON.stringify("File processed successfully!"),
  };
};
